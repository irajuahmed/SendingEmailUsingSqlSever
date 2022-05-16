
-- User parameters
Declare @fromEmail_Address Nvarchar(100) = ''
Declare @fromEmail_Password Nvarchar(100) = ''
Declare @toEmail_Address Nvarchar(MAX) = 'rajuahmed.329@gmail.com'
Declare @profile_name Nvarchar(100) = 'RajuMailService'
Declare @account_nameS Nvarchar(100) = 'RajuMailService'
Declare @mailserver_name Nvarchar(100) = 'smtp.gmail.com' --smtp.live.com	 --smtp.office365.com	

IF EXISTS (SELECT 1 FROM sys.configurations WHERE NAME = 'Database Mail XPs' AND VALUE = 0)
BEGIN
  PRINT 'Enabling Database Mail XPs'
  EXEC sp_configure 'show advanced options', 1;  
  RECONFIGURE
  EXEC sp_configure 'Database Mail XPs', 1;  
  RECONFIGURE  
END


IF NOT EXISTS(SELECT TOP  1 profile_id FROM msdb.dbo.sysmail_profile WHERE [name]=@profile_name)
BEGIN
--Create a new account
EXECUTE msdb.dbo.sysmail_add_account_sp 
		@account_name = @account_nameS, 
		@description = 'Account for Automated DBA Notifications', 
		@email_address = @fromEmail_Address, 
		@replyto_address = @fromEmail_Address, 
		@display_name =@account_nameS, 
		@mailserver_name = @mailserver_name, 
		@port = 587, -- Open port on firewall, no deffrent between smtp server all off them port is 587
		@enable_ssl = 1, 
		@username = @fromEmail_Address, 
		@password = @fromEmail_Password ;


-- Create a default profile
EXECUTE msdb.dbo.sysmail_add_profile_sp 
		@profile_name = @profile_name, 
		@description ='Profile for sending Automated DBA Notifications: ' ;


--Add the Database Mail account to a Database Mail profile
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp 
		@profile_name = @profile_name, 
		@principal_name = 'public', 
		@is_default = 1 ; 

--Add account to profile
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp   
		@profile_name = @profile_name,   
		@account_name = @account_nameS,   
		@sequence_number = 1; 
END


/*
Note:
In order to fix the issue with Gmail, you need to enable the option to "Allow less secure apps". This is a setting in your Gmail account that needs to be enabled.
*/
-- Send test email
EXECUTE msdb.dbo.sp_send_dbmail 
@profile_name = @profile_name, 
@recipients = @toEmail_Address, 
@Subject = 'Testing DBMail', 
@Body = 'Hi,<br/><p style="color:red;">This message is a test for DBMail</p>', 
@body_format ='HTML'
GO


-- Find successfully sent email
SELECT * From msdb.dbo.sysmail_profile


SELECT * From msdb.dbo.sysmail_sentitems

-- Find unsent email
SELECT * From msdb.dbo.sysmail_unsentitems

-- Find failed email attempts
SELECT * From msdb.dbo.sysmail_faileditems
