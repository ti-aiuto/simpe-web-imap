
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
imap.login(imap_username, imap_password)

imap.examine('INBOX')

search_criterias = ["SINCE", Net::IMAP.format_date(Date.new(2022, 12, 10))]
message_ids = imap.search(search_criterias)
message_ids.each_slice(100) do |message_ids|
    p "API呼び出し"
    messages = imap.fetch(message_ids, ["RFC822", "FLAGS"])
    messages.each do |message|
        mail = Mail.new(message.attr["RFC822"])
        p mail.subject
        p mail.from
        p mail.date.to_s
        p message.attr["FLAGS"].include?(:Seen)

        # # multipartなメールかチェック
        # if m.multipart?
        #   # plantextなメールかチェック
        #   if m.text_part
        #     body = m.text_part.decoded
        #   # htmlなメールかチェック
        #   elsif m.html_part
        #     body = m.html_part.decoded
        #   end
        # else
        #   body = m.body
        # end

        # imap.store(msg_id, '+FLAGS', :Seen)
    end
end

imap.logout
