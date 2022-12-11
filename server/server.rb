
require 'net/imap'
require 'date'
require 'mail'

require 'dotenv'
Dotenv.load

imap_host = ENV['SIMPLE_WEB_IMAP_IMAP_HOST']
imap_port = ENV['SIMPLE_WEB_IMAP_IMAP_PORT']
imap_username = ENV['SIMPLE_WEB_IMAP_IMAP_USERNAME']
imap_password = ENV['SIMPLE_WEB_IMAP_IMAP_PASSWORD']
imap_usessl = true

imap = Net::IMAP.new(imap_host, imap_port, imap_usessl)
imap.login(imap_user, imap_password)

imap.examine('INBOX')

search_criterias = ["SINCE", Net::IMAP.format_date(Date.new(2022, 12, 1))]

subject_attr_name = 'BODY[HEADER.FIELDS (SUBJECT)]'
body_attr_name = 'BODY[TEXT]'

imap.search(search_criterias, "RFC822").each do |msg_id|
    messages = imap.fetch(msg_id, [subject_attr_name, body_attr_name])
    p messages

    message = messages.first

    m = Mail.new(message.attr["RFC822"])
    # multipartなメールかチェック
    if m.multipart?
      # plantextなメールかチェック
      if m.text_part
        body = m.text_part.decoded
      # htmlなメールかチェック
      elsif m.html_part
        body = m.html_part.decoded
      end
    else
      body = m.body
    end
end

imap.logout
