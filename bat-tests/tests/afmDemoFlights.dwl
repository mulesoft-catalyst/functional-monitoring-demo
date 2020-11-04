import * from bat::BDD
import * from bat::Assertions
import * from bat::Mutable

var context = HashMap()
var oauth_base64 = config.base64
var app_client_id = config.client_id
var app_client_secret = config.client_secret
var api_endpoint = config.url

---
describe ("AFM-Demo-Flights-API-Suite") in [
  it must 'Create Access Token' in [
    POST `https://mule-oauth2-provider-mp-v1.au-s1.cloudhub.io/aes/external/access-token` with {
      "headers": {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Basic $(oauth_base64)"
        },
        "body": "grant_type=client_credentials&scope=READ" as Binary {encoding: "UTF-8"} 
      } assert [
        $.response.status mustEqual 200,
        $.response.mime mustEqual "application/json"
      ] execute [
          context.set('access_token', $.response.body.access_token)
        ]
    ],
  it must 'Get Flights' in [
    GET `$(api_endpoint)/api/flights?code=SFO&airline=united` with {
      "headers": {
        "client_id": "$(app_client_id)",
        "client_secret": "$(app_client_secret)",
        "Authorization": "Bearer $(context.get('access_token'))"
      }
      } assert [
        $.response.status mustEqual 200,
        $.response.mime mustEqual "application/json"
      ]
  ],
  it must "Get Ping" in [
    GET `$(api_endpoint)/api/ping` with {
      "headers": {
        "client_id": "$(app_client_id)",
        "client_secret": "$(app_client_secret)",
        "Authorization": "Bearer $(context.get('access_token'))"
      }
    } assert [
        $.response.status mustEqual 200,
        $.response.mime mustEqual "application/json"
      ]
  ],
  it must "Post Flights" in [
    POST `$(api_endpoint)/api/flights` with {
      "headers": {
        "client_id": "$(app_client_id)",
        "client_secret": "$(app_client_secret)",
        "Authorization": "Bearer $(context.get('access_token'))"
      },
      body: readUrl('classpath://data/flights.json', 'application/json')
    } assert [
        $.response.status mustEqual 201,
        $.response.mime mustEqual "application/json"
      ]
  ]
]