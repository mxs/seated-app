var Stripe = require('stripe');
var stripeAppId = 'sk_live_gDipJsNBI84HFKSlx1G5AVEN'
var Buffer = require('buffer').Buffer;
var authBase64 = new Buffer(stripeAppId + ":").toString("base64")
var authHeaderValue = "Basic " + authBase64
var express = require('express');
var app = express();

Stripe.initialize(stripeAppId);

Parse.Cloud.define("createCustomerAndSubscribe", function(request, response) {
  var email = request.params["email"]
  var firstName = request.params["first_name"]
  var lastName = request.params["last_name"]

  var params = {
    "email": email,
    "plan": "seated_monthly",
    "metadata": {
      "first_name":firstName,
      "last_name":lastName
    }
  }

  Stripe.Customers.create(params)
  .done(function(result) {
    response.success(result)
  })
  .fail(function(error) {
    response.error(error)
  })

});

Parse.Cloud.define("cancelSubscription", function(request, response) {
  var cancelURL = constructSubscriptionUrl(request)
  var objectId = request.params["objectId"]

  function updateParseSubscription(subscriptionData) {
    var Subscription = Parse.Object.extend("Subscription")
    var query = new Parse.Query(Subscription)
    query.get(objectId)
    .then(function(subscription) {
      subscription.set("cancel_at_period_end", subscriptionData.cancel_at_period_end)
      return subscription.save()
    })
    .then(function() {
      response.success(subscriptionData)
    })
  }

  Parse.Cloud.httpRequest({
    method: "DELETE",
    url: cancelURL,
    params: {
      at_period_end:true
    },
    headers: {
      Authorization: authHeaderValue
    },
    success: function(httpResponse) {
      updateParseSubscription(httpResponse.data)
    },
    error: function(httpResponse) {
      response.error("Request failed with response code " + httpResponse.status)
    }
  });

});


Parse.Cloud.define("retrieveSubscription", function(request, response) {
  var subscriptionUrl = constructSubscriptionUrl(request)
  var objectId = request.params["objectId"]

  function updateParseSubscription(objectId, subscriptionData) {
    var Subscription = Parse.Object.extend("Subscription")
    var query = new Parse.Query(Subscription)
    query.get(objectId, {
      success: function(subscription) {
        subscription.set("status", subscriptionData.status)
        subscription.set("start", new Date(subscriptionData.start * 1000))
        subscription.set("current_period_start", new Date(subscriptionData.current_period_start * 1000))
        subscription.set("current_period_end", new Date(subscriptionData.current_period_end * 1000))
        subscription.set("trial_end", new Date(subscriptionData.trial_end * 1000))
        subscription.set("days_until_trial_end", calcDaysUntilTrialExpiry(subscriptionData.trial_end))
        subscription.set("cancel_at_period_end", subscriptionData.cancel_at_period_end)
        subscription.save()
        response.success(subscriptionData)
      },
      error: function(object, error) {

      }
    })
  }

  function calcDaysUntilTrialExpiry(trialEndDate) {
    var now = Date.now() / 1000
    var elapsed = trialEndDate - now
    return Math.floor(elapsed / 60 / 60 / 24)
  }

  Parse.Cloud.httpRequest({
    url: subscriptionUrl,
    headers: {
      Authorization: authHeaderValue
    }
  })
  .done(function(httpResponse) {
    var data = httpResponse.data
    var id = data["id"]
    var status = data["status"]
    var start = data["start"]
    var current_period_start = data["current_period_start"]
    var current_period_end = data["current_period_end"]
    var trial_end = data["trial_end"]
    var days_until_trial_end = calcDaysUntilTrialExpiry(trial_end)
    var cancel_at_period_end = data["cancel_at_period_end"]
    var subscriptionData = {
      id:id,
      status:status,
      start:start,
      current_period_start:current_period_start,
      current_period_end:current_period_end,
      trial_end:trial_end,
      days_until_trial_end:days_until_trial_end,
      cancel_at_period_end: cancel_at_period_end
    }
    updateParseSubscription(objectId, subscriptionData)
  })
  .fail(function(error) {
    response.error(404)
  })
})

Parse.Cloud.define("reactivateTrialSubscription", function(request, response) {
  var subscriptionUrl = constructSubscriptionUrl(request)
  var objectId = request.params["objectId"]
  var subscription;
  var trial_end;

  var Subscription = Parse.Object.extend("Subscription")
  var query = new Parse.Query(Subscription)
  query.get(objectId)
  .then(function(object) {
    subscription = object
    //get current trial_end
    trial_end = subscription.get("trial_end").getTime() / 1000

    return Parse.Cloud.httpRequest({
      method: "POST",
      url: subscriptionUrl,
      body: {
        trial_end:trial_end
      },
      headers: {
        Authorization: authHeaderValue
      }
    })
  })
  .then(function(httpResponse) {
    subscription.set("cancel_at_period_end", false)
    return subscription.save()
  })
  .then(function() {
    response.success("reactivated")
  })
  .fail(function(error) {
    response.error(error)
  })
})

Parse.Cloud.define("createSubscription", function(request, response) {
  var customerId = request.params["customer_id"]
  var token = request.params["token"]
  var url = "https://api.stripe.com/v1/customers/" + customerId + "/subscriptions"
  var subscriptionData

  Parse.Cloud.httpRequest({
    method: "POST",
    url:url,
    headers: {
      Authorization: authHeaderValue
    },
    body: {
      plan: "seated_monthly",
      trial_end: "now",
      card: token
    }
  })
  .then(function(httpResponse) {
    var data = httpResponse.data
    var id = data["id"]
    var status = data["status"]
    var start = data["start"]
    var current_period_start = data["current_period_start"]
    var current_period_end = data["current_period_end"]
    var trial_end = data["trial_end"]
    var days_until_trial_end = 0
    var cancel_at_period_end = data["cancel_at_period_end"]
    subscriptionData = {
      id:id,
      status:status,
      start:start,
      current_period_start:current_period_start,
      current_period_end:current_period_end,
      trial_end:trial_end,
      days_until_trial_end:days_until_trial_end,
      cancel_at_period_end: cancel_at_period_end
    }

    return Parse.Cloud.httpRequest({
      url:"https://api.stripe.com/v1/customers/" + customerId + "/cards",
      headers: {
        Authorization: authHeaderValue
      }
    })
  })
  .then(function(httpResponse) {
    var card = httpResponse.data.data[0]
    subscriptionData["card_id"] = card.id
    subscriptionData["card_label"] = constructCardLabel(card)
    response.success(subscriptionData)
  })
  .fail(function(error) {
    response.error(error)
  })
})

Parse.Cloud.define("updateCustomerCard", function(request, response) {
  var url = "https://api.stripe.com/v1/customers/" + request.params["customer_id"] + "/cards"
  var tokenId = request.params["token_id"]
  var currentCard = request.params["card_id"]

  Parse.Cloud.httpRequest({
    method: "POST",
    url: url,
    headers: {
      Authorization: authHeaderValue
    },
    body: {
        card: tokenId
    }
  })
  .done(function(httpResponse) {
    // only remove the current card successfully adding new card
    if (typeof currentCard != "undefined") {
      deleteCustomerCard(url, currentCard)
    }
    var cardId = httpResponse.data.id
    var cardBrand = httpResponse.data.brand
    var last4 = httpResponse.data.last4
    var expiry = httpResponse.data.exp_month + "/" + httpResponse.data.exp_year
    var cardLabel = constructCardLabel(httpResponse.data)
    response.success({card_id:cardId, card_label:cardLabel})
  })
  .fail(function(error) {
    response.error(error)
  })
})

function deleteCustomerCard(baseUrl, cardId) {
  var url = baseUrl + "/" + cardId
  Parse.Cloud.httpRequest({
    method: "DELETE",
    url: url,
    headers: {
      Authorization: authHeaderValue
    }
  })
  .done(function(httpResponse) {
    console.log(httpResponse.status)
  })
  .fail(function(httpResponse) {
    console.log(httpResponse.status)
  })
}

function constructSubscriptionUrl(request) {
  var customerId = request.params["stripeCustomerId"]
  var subscriptionId = request.params["subscriptionId"]
  return "https://api.stripe.com/v1/customers/" + customerId + "/subscriptions/" + subscriptionId
}

function constructCardLabel(card) {
  var cardBrand = card.brand
  var last4 = card.last4
  var expiry = card.exp_month + "/" + card.exp_year
  var cardLabel = cardBrand + " ****" + last4 + " " + expiry
  return cardLabel
}


// ExpressJS for Stripe Webhooks
app.use(express.bodyParser());

app.post("/webhook/subscription/deleted", function(request, response) {
  Parse.Cloud.useMasterKey();

  var event_json = request.body
  var User = Parse.Object.extend("User")
  var foundUser;

  Stripe.Events.retrieve(event_json.id)
  .then(function(event) {
    if (event.type == "customer.subscription.deleted") {
      var query = new Parse.Query(User)
      query.equalTo("stripeCustomerId", event_json.data.object.customer)
      return query.first()
    }
  })
  .then(function(user) {
    foundUser = user
    var subscription = user.get("subscription")
    return subscription.fetch()
  })
  .then(function(subscription) {
    subscription.set("status", "canceled")
    return subscription.save()
  })
  .then(function() {
    response.status(200).send("Deleted")
  })
  .fail(function(error) {
    response.status(500).send("Error")
  })

})

app.post("/webhook/customer/created", function(request, response) {
  var event_json = request.body
  var customer = event_json.data.object
  var email = customer["email"]
  var fullName = customer["metadata"].first_name + " " + customer["metadata"].last_name
  var mandrillURL = "https://mandrillapp.com/api/1.0/messages/send-template.json"
  var mandrillPayload = {
    key: "NryI_cDMFCKaeTEDZUy6iQ",
    template_name: "seated-transactional-signup",
    template_content: [
      {
        name:"",
        content:""
      }
    ],
    message: {
      to: [
        {
          email:email,
          name:fullName,
          type:"to"
        }
      ]
    },
    async:false
  }

  Parse.Cloud.httpRequest({
    method: "POST",
    url: mandrillURL,
    body: JSON.stringify(mandrillPayload)
  })
  .done(function(httpResponse) {
    response.status(200).send(httpResponse.data)
  })
  .fail(function(error) {
    response.status(500).send("Error sending welcome email")
  })
})

app.listen()
