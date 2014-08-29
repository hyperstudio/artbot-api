## POST   /registrations

Register a user. Does not require an `authentication_token`

### Request Parameters

| Field                   | Required | Notes
| ---                     | ---      | ---
| `email`                 | Yes      |
| `password`              | Yes      |
| `password_confirmation` | Yes      |
| `zipcode`               | No       |

### Successful Response

Response Code: 200

Payload: A serialized user.


```
{"user":{"id":1,"email":"foo@example.com","authentication_token":"asdfasdfasdf","zipcode":"01902","send_weekly_emails":false,"send_day_before_event_reminders":false,"send_week_before_close_reminders":false}}
```

### Unsuccessful Response

Response Code: 422

Payload: Serialized attribute errors


```
{"password":["can't be blank"],"password_confirmation":["doesn't match Password"]}
```

## PATCH or PUT to /preferences

Updates a users preferences. Requires an `authentication_token`. If a parameter
is not in the request, it will not be modified.

### Request Parameters

| Field                                 | Required | Notes
| ---                                   | ---      | ---
| `send_weekly_emails`                  | No       | Boolean
| `send_day_before_event_reminders`     | No       | Boolean
| `send_week_before_close_reminders`    | No       | Boolean
| `password`                            | No       |
| `password_confirmation`               | No       |
| `zipcode`                             | No       |

### Successful response

Response Code: 200

Payload: A serialized user.


```
{"user":{"id":1,"email":"foo@example.com","authentication_token":"asdfasdfasdf","zipcode":"01902","send_weekly_emails":false,"send_day_before_event_reminders":false,"send_week_before_close_reminders":false}}
```

### Unsuccessful response

Response Code: 422

Payload: Serialized attribute errors


```
{"password":["is too short (minimum is 8 characters)"]}
```

## GET /preferences

Gets a users preferences. Requires an `authentication_token`.

### Successful Response

Response Code: 200

Payload: A serialized user.


```
{"user":{"id":1,"email":"foo@example.com","authentication_token":"asdfasdfasdf","zipcode":"01902","send_weekly_emails":false,"send_day_before_event_reminders":false,"send_week_before_close_reminders":false}}
```

### Unsuccessful Response

Response Code: 500?

## GET /possible_interests

Gets a serialized list of interests a user can indicate, which are Admin owned
tags. Does not require authentication.

### Successful Response

Response Code: 200

Payload: A list of possible tags a user can choose as interests


```
{"tags":[{"id":2,"name":"bar"},{"id":3,"name":"baz"},{"id":1,"name":"foo"}]}
```

### Unsuccessful Response

Response Code: 500?

## GET /interests

Get a list of the current_users interests. Requires an `authentication_token`.

### Successful Response

Response Code: 200

Payload: A list of the interests (including the tags) a user has indicated.


```
{"interests":[{"id":1,"tag":{"id":1,"name":"foo","taggings_count":1}}]}
```

### Unsuccessful Response

Response Code: 500?

## POST /interests

Indicate that a tag is of interest. Requires an `authentication_token`.

### Request Parameters

| Field                   | Required | Notes
| ---                     | ---      | ---
| `tag_id`                | Yes      | A tag_id in the list from /possible_interests

### Successful Response

Response Code: 200

Payload: A serialized interest with the tag information.


```
{"interest":{"id":1,"tag":{"id":1,"name":"foo","taggings_count":1}}}
```

### Unsuccessful Response

Response Code: 500?

## DELETE /interests/:id

Delete an interest by its `id`. Requires an `authentication_token`.

### Successful Response

Response Code: 204

Payload: none.

### Unsuccessful Response

Response Code: 500?

## GET /favorites/history

A paginated list of favorited events with past `end_date`s.  Requires an
`authentication_token`.

### Request Parameters

| Field                   | Required | Notes
| ---                     | ---      | ---
| `page`                  | No       | Request this page. Defaults to 1.
| `per_page`              | No       | This many per page. Defaults to 5.

### Successful Response

Response Code: 200

Payload: A serialized list of favorited events that include location and
pagination metadata.


```
{"favorites":[{"id":1,"created_at":"2014-08-14T20:28:39.313Z","attended":false,"event":{"id":1,"name":"Event 1","url":"http://www.example.com/2","description":null,"image":null,"dates":"May 20, 2014 - June 1, 2014","event_type":"exhibition","start_date":null,"end_date":"2014-08-12T20:28:39.284Z","location":{"id":1,"name":"Museum of Fine Arts, Boston","url":"http://www.example.com/1","description":"The Museum of Fine Arts in Boston, Massachusetts, is one of the largest museums in the United States. It contains more than 450,000 works of art, making it one of the most comprehensive collections in the Americas. With more than one million visitors a year, it is (as of 2013) the 62nd most-visited art museum in the world.\n\nFounded in 1870, the museum moved to its current location in 1909. The museum is affiliated with an art academy, the School of the Museum of Fine Arts, and a sister museum, the Nagoya/Boston Museum of Fine Arts, in Nagoya, Japan. The director of the museum is Malcolm Rogers.","image":"http://www.mfa.org/sites/default/files/imagecache/showcase_2/images/Fenway%20at%20dusk_0.jpg","latitude":42.3394675,"longitude":-71.0948962}}}],"meta":{"current_page":1,"next_page":null,"prev_page":null,"per_page":5,"total_pages":1}}
```

### Unsuccessful Response

Response Code: 500?

## GET /favorites

A paginated list of all the user's favorites, newest first. Essentially the
same as the '/favorites/history' endpoint, except that it's all of a user's
favorites.  Requires an `authentication_token`.

## PATCH or PUT /favorites/:id

Update a user's favorite for an event most likely to toggle the state of the
`attended` boolean attribute. Requires an `authentication_token`.

| Field                   | Required | Notes
| ---                     | ---      | ---
| `attended`              | Yes      | Boolean

### Successful Response

Response Code: 201

Payload: A serialized favorite with the event and location.

```
{favorite":{"id":1,"created_at":"2014-08-14T20:39:48.599Z","attended":true,"event":{"id":1,"name":"Event 1","url":"http://www.example.com/2","description":null,"image":null,"dates":"May 20, 2014 - June 1, 2014","event_type":"exhibition","start_date":null,"end_date":null,"location":{"id":1,"name":"Museum of Fine Arts, Boston","url":"http://www.example.com/1","description":"The Museum of Fine Arts in Boston, Massachusetts, is one of the largest museums in the United States. It contains more than 450,000 works of art, making it one of the most comprehensive collections in the Americas. With more than one million visitors a year, it is (as of 2013) the 62nd most-visited art museum in the world.\n\nFounded in 1870, the museum moved to its current location in 1909. The museum is affiliated with an art academy, the School of the Museum of Fine Arts, and a sister museum, the Nagoya/Boston Museum of Fine Arts, in Nagoya, Japan. The director of the museum is Malcolm Rogers.","image":"http://www.mfa.org/sites/default/files/imagecache/showcase_2/images/Fenway%20at%20dusk_0.jpg","latitude":42.3394675,"longitude":-71.0948962}}}}
```

### Unsuccessful Response

Response Code: 422

Payload: A serialized list of errors.

## GET /events/:id

Gets an event.

| Field                   | Required | Notes
| ---                     | ---      | ---
| `related`               | No       | Boolean

### Successful Response

Response Code: 200

Payload: A serialized event with location. If `related` is `true`, also includes a serialized list of tags with respective related events.

```
{"event":{"id":1,"name":"Event 3","url":"http://www.example.com/6","description":null,"image":null,"dates":"May 20, 2014 - June 1, 2014","event_type":"exhibition","start_date":null,"end_date":"2014-08-31T20:44:15.739Z","related":[{"tag":{"id":1,"name":"Tag 1","taggings_count":1},"events":[{"id":2,"created_at":"2014-08-29T20:44:15.755Z","updated_at":"2014-08-29T20:44:15.755Z","location_id":2,"name":"Event 4","url":"http://www.example.com/8","description":null,"image":null,"dates":"May 20, 2014 - June 1, 2014","event_type":"exhibition","start_date":null,"end_date":"2014-08-31T20:44:15.753Z"}]},{"tag":{"id":2,"name":"Tag 2","taggings_count":1},"events":[{"id":3,"created_at":"2014-08-29T20:44:15.764Z","updated_at":"2014-08-29T20:44:15.764Z","location_id":3,"name":"Event 5","url":"http://www.example.com/10","description":null,"image":null,"dates":"May 20, 2014 - June 1, 2014","event_type":"exhibition","start_date":null,"end_date":"2014-08-31T20:44:15.762Z"}],"score":-1},{"tag":{"id":3,"name":"Entity 2","url":null,"description":null,"refcount":null,"stanford_name":null,"entity_type":"person","score":null,"type_group":null},"events":[{"id":4,"created_at":"2014-08-29T20:44:15.796Z","updated_at":"2014-08-29T20:44:15.796Z","location_id":4,"name":"Event 6","url":"http://www.example.com/12","description":null,"image":null,"dates":"May 20, 2014 - June 1, 2014","event_type":"exhibition","start_date":null,"end_date":"2014-08-31T20:44:15.794Z"}],"score":-101}],"location":{"id":1,"name":"Museum of Fine Arts, Boston","url":"http://www.example.com/5","description":"The Museum of Fine Arts in Boston, Massachusetts, is one of the largest museums in the United States. It contains more than 450,000 works of art, making it one of the most comprehensive collections in the Americas. With more than one million visitors a year, it is (as of 2013) the 62nd most-visited art museum in the world.\n\nFounded in 1870, the museum moved to its current location in 1909. The museum is affiliated with an art academy, the School of the Museum of Fine Arts, and a sister museum, the Nagoya/Boston Museum of Fine Arts, in Nagoya, Japan. The director of the museum is Malcolm Rogers.","image":"http://www.mfa.org/sites/default/files/imagecache/showcase_2/images/Fenway%20at%20dusk_0.jpg","latitude":42.3394675,"longitude":-71.0948962}}}
```

### Unsuccessful Response

Response Code: 500?


## TO FINISH DOCUMENTING

```
DELETE /favorites/:id(.:format)                 favorites#destroy
GET    /discoveries(.:format)                   discoveries#index
POST   /events/:event_id/favorite(.:format)     favorites#create
GET    /events(.:format)                        events#index
GET    /locations/:location_id/events(.:format) events#index
GET    /locations(.:format)                     locations#index
GET    /locations/:id(.:format)                 locations#show
POST   /tokens(.:format)                        tokens#create
```
