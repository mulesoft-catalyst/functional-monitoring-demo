import * from bat::BDD
import * from bat::Assertions
import * from bat::Mutable
import toBase64 from dw::core::Binaries
import * from dw::util::Values

var context = HashMap()
var oauth_client_id = secret('oauthClientIdAlias') default 'OAuth Client ID Not Found'
var oauth_client_secret = secret('oauthClientSecretAlias') default 'OAuth Client Secret Not Found'
var app_client_id = secret('appClientIdAlias') default 'App Client ID Not Found'
var app_client_secret = secret('appClientSecretAlias') default 'App Client Secret Not Found'
var api_endpoint = config.url

fun encodeCreds() = toBase64(oauth_client_id ++ ':' ++ oauth_client_secret)

---
describe ("AFM-Demo-Flights-API-Suite") in [
  it must 'Create Access Token' in [
    POST `https://mule-oauth2-provider-mp-v1.au-s1.cloudhub.io/aes/external/access-token` with {
      "headers": {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Basic " ++ encodeCreds()
        },
        "body": "grant_type=client_credentials&scope=READ" as Binary {encoding: "UTF-8"} 
      } assert [
        $.response.status mustEqual 200,
        $.response.mime mustEqual "application/json"
      ] execute [
          context.set('access_token', $.response.body.access_token)
        ] mask field("access_token") with "*****" mask field("refresh_token") with "*****" 
    ] mask field("Authorization") with "*****",
  it must 'Get Flights' in [
    GET `$(api_endpoint)/api/flights?code=SFO&airline=united` with {
      "headers": {
        "client_id": app_client_id,
        "client_secret": app_client_secret,
        "Authorization": "Bearer $(context.get('access_token'))"
      }
      } assert [
        $.response.status mustEqual 200,
        $.response.mime mustEqual "application/json"
      ]
  ] mask field("Authorization") with "*****",
  it must "Get Ping" in [
    GET `$(api_endpoint)/api/ping` with {
      "headers": {
        "client_id": app_client_id,
        "client_secret": app_client_secret,
        "Authorization": "Bearer $(context.get('access_token'))"
      }
    } assert [
        $.response.status mustEqual 200,
        $.response.mime mustEqual "application/json"
      ]
  ] mask field("Authorization") with "*****",
  it must "Post Flights" in [
    POST `$(api_endpoint)/api/flights` with {
      "headers": {
        "client_id": app_client_id,
        "client_secret": app_client_secret,
        "Authorization": "Bearer $(context.get('access_token'))"
      },
      body: readUrl('classpath://data/flights.json', 'application/json')
    } assert [
        $.response.status mustEqual 201,
        $.response.mime mustEqual "application/json"
      ]
  ] mask field("Authorization") with "*****"
]