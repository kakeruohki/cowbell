require 'sinatra'
require 'line/bot'

CHANNEL_ID = '1653480883'
CHANNEL_SECRET = '9b1fb9aeb218f04bafd51392755bf584'
CHANNEL_TOKEN = '331XWRc2PW4MRcbavb3gKdgblvfKOcb8t01U87I71RkP2iYqDoWPN1I0LTgvvvH7NA3qS0wBFiEkvE8E8/AbFbwHDSIx3SEn6/rhoyIuuUBISWwrvmWRdo38mLcrD7gczmauW4otsntecTjZX5m87gdB04t89/1O/w1cDnyilFU='

get '/' do
  "Hello world"
end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          text: "あざす"
        }
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  }

  "OK"
end
