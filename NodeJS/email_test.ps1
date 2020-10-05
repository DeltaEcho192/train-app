#SMTP Data
$EmailFrom = "xortest@vanoli-ag.ch"
$EmailPW = "V@noli-8833"
$EmailTo = "anthony.durrer@vanoli-ag.ch"
$SMTPServer = "mail.vanoli-ag.ch"
$Subject = 'Mailtest'

$message = new-object System.Net.Mail.MailMessage 
$message.From = $EmailFrom 
$message.To.Add($EmailTo)
$message.IsBodyHtml = $True 
$message.Subject = $Subject 
$Body = "Mailtest!"

#$attach = new-object Net.Mail.Attachment($Logfile) 
#$message.Attachments.Add($attach) 

$message.body = $Body 

$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25)
$SMTPClient.EnableSsl = $false
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Emailfrom,$EmailPW);
$SMTPClient.Send($message)
