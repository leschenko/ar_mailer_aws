AWS.config(
    :access_key_id => 'YOUR_ACCESS_KEY_ID',
    :secret_access_key => 'YOUR_SECRET_ACCESS_KEY'
)

<% if class_name != 'BatchEmail' -%>
ArMailerAWS.email_class = '<%= class_name %>'
<% end -%>

#ActionMailer::Base.delivery_method = :ar_mailer_aws