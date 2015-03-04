Parse.Cloud.define("sendWelcomeEmail", function(request, response) {
  var email = request.params["email"]
  var fullName = request.params["fullname"]
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
    response.success("Welcome email sent")
  })
  .fail(function(error) {
    response.error(error)
  })
})
