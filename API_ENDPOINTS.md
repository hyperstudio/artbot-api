## HEAD or GET /registrations

Check if a user is registered.

### Request Parameters

| Field                   | Required | Notes
| ---                     | ---      | ---
| `email`                 | Yes      |

### Successful Response

Response Code: 200.

Payload: None.

### Unsuccessful Response

Response Code: 404.

## POST /registrations

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
{"user"=>{"id"=>2, "email"=>"user@example.com", "authentication_token"=>"1F4WJvwV2P4cQiAmY53o", "zipcode"=>"11211", "send_weekly_emails"=>false, "send_day_before_event_reminders"=>false, "send_week_before_close_reminders"=>false, "remember_created_at"=>"2015-01-08T16:12:35.088Z"}}
```

### Unsuccessful Response

Response Code: 422

Payload: Serialized attribute errors


```
{"password":["can't be blank"],"password_confirmation":["doesn't match Password"]}
```

## PATCH /registrations

Sends a password reset email to a user.

### Request Parameters

| Field                   | Required | Notes
| ---                     | ---      | ---
| `email`                 | Yes      |

### Successful Response

Response Code: 200

Payload: None.

### Unsuccessful Response

Response Code: 404

## PUT /registrations

Updates a user password using a reset token.

### Request Parameters

| Field                   | Required | Notes
| ---                     | ---      | ---
| `password`              | Yes      |
| `password_confirmation` | Yes      |
| `reset_password_token`  | Yes      |

### Successful Response

Response Code: 200

Payload: A serialized user.


```
{"user"=>{"id"=>2, "email"=>"user@example.com", "authentication_token"=>"1F4WJvwV2P4cQiAmY53o", "zipcode"=>"11211", "send_weekly_emails"=>false, "send_day_before_event_reminders"=>false, "send_week_before_close_reminders"=>false, "remember_created_at"=>"2015-01-08T16:12:35.088Z"}}
```

### Unsuccessful Response

Response Code: 422

Payload: Serialized attribute errors

```
{"password":["can't be blank"],"password_confirmation":["doesn't match Password"]}
```

Response Code: 404

Payload: Error message

```
{"error":"User does not exist"}
```

## POST /tokens

Retrieves a user's authentication token.

### Request Parameters

| Field                   | Required | Notes
| ---                     | ---      | ---
| `email`                 | Yes      | Email for authenticating user.
| `password`              | Yes      | Password for authenticating user.

### Successful Response

Response Code: 200

Payload: An authentication token.


```
{"authentication_token":"6f7xykDYiBrgBWxbmuqs"}
```

### Unsuccessful Response

Response Code: 404

Payload: An error response stating that the user could not be found.


```
{"error": "User does not exist"}
```

Response Code: 403

Payload: An error response stating that user authentication failed.

```
{"error": "Authentication failed"}
```

## GET /preferences

Gets a users preferences. Requires an `authentication_token`.

### Successful Response

Response Code: 200

Payload: A serialized user.


```
{"user"=>{"id"=>2, "email"=>"user@example.com", "authentication_token"=>"1F4WJvwV2P4cQiAmY53o", "zipcode"=>"11211", "send_weekly_emails"=>false, "send_day_before_event_reminders"=>false, "send_week_before_close_reminders"=>false, "remember_created_at"=>"2015-01-08T16:12:35.088Z"}}
```

### Unsuccessful Response

Response Code: 500?

## PATCH or PUT to /preferences

Updates a users preferences. Requires an `authentication_token`. If a parameter
is not in the request, it will not be modified.

### Request Parameters

| Field                                 | Required | Notes
| ---                                   | ---      | ---
| `send_weekly_emails`                  | No       | Boolean
| `send_day_before_event_reminders`     | No       | Boolean
| `send_week_before_close_reminders`    | No       | Boolean
| `remember_me`							| No 	   | Boolean
| `password`                            | No       |
| `password_confirmation`               | No       |
| `zipcode`                             | No       |

### Successful response

Response Code: 200

Payload: A serialized user.


```
{"user"=>{"id"=>2, "email"=>"user@example.com", "authentication_token"=>"1F4WJvwV2P4cQiAmY53o", "zipcode"=>"11211", "send_weekly_emails"=>false, "send_day_before_event_reminders"=>false, "send_week_before_close_reminders"=>false, "remember_created_at"=>"2015-01-08T16:12:35.088Z"}}
```

### Unsuccessful response

Response Code: 422

Payload: Serialized attribute errors


```
{"password":["is too short (minimum is 8 characters)"]}
```

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
| `tag_id`                | Yes      | A tag_id in the list from `/possible_interests`

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

Payload: None.

### Unsuccessful Response

Response Code: 500?

## GET /favorites

A paginated list of all the user's favorites, newest first. Requires an `authentication_token`.

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

## GET /favorites/history

A paginated list of favorited events with past `end_date`s.
Similar to `GET /favorites`, only with past events instead of current ones.
Requires an `authentication_token`.

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

## POST /favorites/:id

Favorites an event for a user. Requires an `authentication_token`.

### Request Parameters

| Field                   | Required | Notes
| ---                     | ---      | ---
| `attended`              | No       | Boolean. Defaults to false.

### Successful Response

Response Code: 201

Payload: A serialized favorite with the event and location.

```
{"favorite":{"id":1,"created_at":"2014-09-07T19:52:21.914Z","attended":null,"event":{"id":1,"name":"Event 7","url":"http://www.example.com/14","description":null,"image":null,"dates":"No end date! Defaulted.","event_type":"exhibition","start_date":"2014-09-07T19:52:21.898Z","end_date":"2015-09-07T19:52:21.898Z","location":{"id":1,"name":"Museum of Fine Arts, Boston","url":"http://www.example.com/13","description":"The Museum of Fine Arts in Boston, Massachusetts, is one of the largest museums in the United States. It contains more than 450,000 works of art, making it one of the most comprehensive collections in the Americas. With more than one million visitors a year, it is (as of 2013) the 62nd most-visited art museum in the world.\n\nFounded in 1870, the museum moved to its current location in 1909. The museum is affiliated with an art academy, the School of the Museum of Fine Arts, and a sister museum, the Nagoya/Boston Museum of Fine Arts, in Nagoya, Japan. The director of the museum is Malcolm Rogers.","image":"http://www.mfa.org/sites/default/files/imagecache/showcase_2/images/Fenway%20at%20dusk_0.jpg","latitude":42.3394675,"longitude":-71.0948962,"address":null,"hours":null}}}}
```

### Unsuccessful Response

Response Code: 500?

## PATCH or PUT /favorites/:id

Update a user's favorite for an event most likely to toggle the state of the
`attended` boolean attribute. Requires an `authentication_token`.

### Request Parameters.

| Field                   | Required | Notes
| ---                     | ---      | ---
| `attended`              | Yes      | Boolean

### Successful Response

Response Code: 201

Payload: A serialized favorite with the event and location, same as `POST /favorites/:id`

### Unsuccessful Response

Response Code: 422

Payload: A serialized list of errors.

## DELETE /favorites/:id

Un-favorite an event for a user. Requires an `authentication_token`.

### Successful Response

Response Code: 204

Payload: None.

### Unsuccessful Response

Response Code: 500?

## GET /events/:id

Gets an event.

### Request Parameters

| Field                   | Required | Notes
| ---                     | ---      | ---
| `related`               | No       | Boolean. Defaults to false.

### Successful Response

Response Code: 200

Payload: A serialized event with location. If `related` is `true`, also includes a serialized list of tags (under the `related` key) with respective related events.

```
{"event":{"id":1,"name":"Event 3","url":"http://www.example.com/6","description":null,"image":null,"dates":"May 20, 2014 - June 1, 2014","event_type":"exhibition","start_date":null,"end_date":"2014-08-31T20:44:15.739Z","related":[{"tag":{"id":1,"name":"Tag 1","taggings_count":1},"events":[{"id":2,"created_at":"2014-08-29T20:44:15.755Z","updated_at":"2014-08-29T20:44:15.755Z","location_id":2,"name":"Event 4","url":"http://www.example.com/8","description":null,"image":null,"dates":"May 20, 2014 - June 1, 2014","event_type":"exhibition","start_date":null,"end_date":"2014-08-31T20:44:15.753Z"}]},{"tag":{"id":2,"name":"Tag 2","taggings_count":1},"events":[{"id":3,"created_at":"2014-08-29T20:44:15.764Z","updated_at":"2014-08-29T20:44:15.764Z","location_id":3,"name":"Event 5","url":"http://www.example.com/10","description":null,"image":null,"dates":"May 20, 2014 - June 1, 2014","event_type":"exhibition","start_date":null,"end_date":"2014-08-31T20:44:15.762Z"}],"score":-1},{"tag":{"id":3,"name":"Entity 2","url":null,"description":null,"refcount":null,"stanford_name":null,"entity_type":"person","score":null,"type_group":null},"events":[{"id":4,"created_at":"2014-08-29T20:44:15.796Z","updated_at":"2014-08-29T20:44:15.796Z","location_id":4,"name":"Event 6","url":"http://www.example.com/12","description":null,"image":null,"dates":"May 20, 2014 - June 1, 2014","event_type":"exhibition","start_date":null,"end_date":"2014-08-31T20:44:15.794Z"}],"score":-101}],"location":{"id":1,"name":"Museum of Fine Arts, Boston","url":"http://www.example.com/5","description":"The Museum of Fine Arts in Boston, Massachusetts, is one of the largest museums in the United States. It contains more than 450,000 works of art, making it one of the most comprehensive collections in the Americas. With more than one million visitors a year, it is (as of 2013) the 62nd most-visited art museum in the world.\n\nFounded in 1870, the museum moved to its current location in 1909. The museum is affiliated with an art academy, the School of the Museum of Fine Arts, and a sister museum, the Nagoya/Boston Museum of Fine Arts, in Nagoya, Japan. The director of the museum is Malcolm Rogers.","image":"http://www.mfa.org/sites/default/files/imagecache/showcase_2/images/Fenway%20at%20dusk_0.jpg","latitude":42.3394675,"longitude":-71.0948962}}}
```

### Unsuccessful Response

Response Code: 500?

## GET /events

Gets a paginated list of events.

### Request Parameters

*NOTE: Currently the API limits by either time or location, not both.
You can use `year`/`month`/`day` or `latitude`/`longitude`/`radius`, but don't use both.*

| Field                   | Required | Notes
| ---                     | ---      | ---
| `related`               | No       | Boolean. Defaults to false.
| `year`                  | No       | Integer. Limit to events going on this year.
| `month`                 | No       | Integer. Limit to events going on this month.<br>Requires `year`
| `day`                   | No       | Integer. Limit to events going on this day.<br>Requires `year` and `month`
| `latitude`              | No       | Float. Limit to events near this latitude.<br>Requires `longitude`
| `longitude`             | No       | Float. Limit to events near this longitude.<br>Requires `latitude`
| `radius`                | No       | Integer. Distance from `latitude` and `longitude` to limit.<br>Requires `latitude` and `longitude`. In miles. Defaults to 10.
| `page`                  | No       | Request this page. Defaults to 1.
| `per_page`              | No       | This many per page. Defaults to 5.

### Successful Response

Response Code: 200

Payload: A list of events serialized similarly to `GET /events/:id`. Includes a `meta` hash with pagination information.

```
{"events":[{"id":1,"name":"Event 17","url":"http://www.example.com/32","description":null,"image":null,"dates":"","event_type":"exhibition","start_date":"2014-09-07T19:07:53.125Z","end_date":"2015-09-07T19:07:53.126Z","location":{"id":1,"name":"Museum of Fine Arts, Boston","url":"http://www.example.com/31","description":"The Museum of Fine Arts in Boston, Massachusetts, is one of the largest museums in the United States. It contains more than 450,000 works of art, making it one of the most comprehensive collections in the Americas. With more than one million visitors a year, it is (as of 2013) the 62nd most-visited art museum in the world.\n\nFounded in 1870, the museum moved to its current location in 1909. The museum is affiliated with an art academy, the School of the Museum of Fine Arts, and a sister museum, the Nagoya/Boston Museum of Fine Arts, in Nagoya, Japan. The director of the museum is Malcolm Rogers.","image":"http://www.mfa.org/sites/default/files/imagecache/showcase_2/images/Fenway%20at%20dusk_0.jpg","latitude":42.3394675,"longitude":-71.0948962,"address":null,"hours":null}},{"id":2,"name":"Event 18","url":"http://www.example.com/34","description":null,"image":null,"dates":"","event_type":"exhibition","start_date":"2014-09-07T19:07:53.137Z","end_date":"2015-09-07T19:07:53.137Z","location":{"id":2,"name":"Museum of Fine Arts, Boston","url":"http://www.example.com/33","description":"The Museum of Fine Arts in Boston, Massachusetts, is one of the largest museums in the United States. It contains more than 450,000 works of art, making it one of the most comprehensive collections in the Americas. With more than one million visitors a year, it is (as of 2013) the 62nd most-visited art museum in the world.\n\nFounded in 1870, the museum moved to its current location in 1909. The museum is affiliated with an art academy, the School of the Museum of Fine Arts, and a sister museum, the Nagoya/Boston Museum of Fine Arts, in Nagoya, Japan. The director of the museum is Malcolm Rogers.","image":"http://www.mfa.org/sites/default/files/imagecache/showcase_2/images/Fenway%20at%20dusk_0.jpg","latitude":42.3394675,"longitude":-71.0948962,"address":null,"hours":null}}],"meta":{"current_page":1,"next_page":null,"prev_page":null,"per_page":5,"total_pages":1}}
```

### Unsuccessful Response

Response Code: 500?

## GET /locations/:location_id/events

Gets a paginated list of current events at a given location.

### Request Parameters

| Field                   | Required | Notes
| ---                     | ---      | ---
| `related`               | No       | Boolean. Defaults to false.
| `page`                  | No       | Request this page. Defaults to 1.
| `per_page`              | No       | This many per page. Defaults to 5.

### Successful Response

Response Code: 200

Payload: A list of events serialized like in `GET /events`. Includes a `meta` hash with pagination information.

### Unsuccessful Response

Response Code: 500?

##  GET /discoveries

Gets event discoveries tailored to a user. If no `authentication_token` is provided, defaults to getting events by date.

### Request Parameters

| Field                   | Required | Notes
| ---                     | ---      | ---
| `page`                  | No       | Request this page. Defaults to 1.
| `per_page`              | No       | This many per page. Defaults to 5.

### Successful Response

Response Code: 200

Payload: A list of events serialized like in `GET /events`. Includes a `meta` hash with pagination information.

### Unsuccessful Response

Response Code: 500?

##  GET /locations

Gets a paginated list of locations.

### Request Parameters

| Field                   | Required | Notes
| ---                     | ---      | ---
| `page`                  | No       | Request this page. Defaults to 1.
| `per_page`              | No       | This many per page. Defaults to 5.

### Successful Response

Response Code: 200

Payload: A serialized list of locations, with pagination information.

```
{"locations":[{"id":1,"name":"Museum of Fine Arts, Boston","url":"http://www.example.com/2","description":"The Museum of Fine Arts in Boston, Massachusetts, is one of the largest museums in the United States. It contains more than 450,000 works of art, making it one of the most comprehensive collections in the Americas. With more than one million visitors a year, it is (as of 2013) the 62nd most-visited art museum in the world.\n\nFounded in 1870, the museum moved to its current location in 1909. The museum is affiliated with an art academy, the School of the Museum of Fine Arts, and a sister museum, the Nagoya/Boston Museum of Fine Arts, in Nagoya, Japan. The director of the museum is Malcolm Rogers.","image":"http://www.mfa.org/sites/default/files/imagecache/showcase_2/images/Fenway%20at%20dusk_0.jpg","latitude":42.3394675,"longitude":-71.0948962,"address":null,"hours":null},{"id":2,"name":"Museum of Fine Arts, Boston","url":"http://www.example.com/3","description":"The Museum of Fine Arts in Boston, Massachusetts, is one of the largest museums in the United States. It contains more than 450,000 works of art, making it one of the most comprehensive collections in the Americas. With more than one million visitors a year, it is (as of 2013) the 62nd most-visited art museum in the world.\n\nFounded in 1870, the museum moved to its current location in 1909. The museum is affiliated with an art academy, the School of the Museum of Fine Arts, and a sister museum, the Nagoya/Boston Museum of Fine Arts, in Nagoya, Japan. The director of the museum is Malcolm Rogers.","image":"http://www.mfa.org/sites/default/files/imagecache/showcase_2/images/Fenway%20at%20dusk_0.jpg","latitude":42.3394675,"longitude":-71.0948962,"address":null,"hours":null}],"meta":{"current_page":1,"next_page":null,"prev_page":null,"per_page":5,"total_pages":1}}
```

### Unsuccessful Response

Response Code: 500?

##  GET /locations/:id

Gets a single location.

### Successful Response

Response Code: 200

Payload: A serialized location.

```
{"location":{"id":1,"name":"A location","url":"http://www.example.com/1","description":"The Museum of Fine Arts in Boston, Massachusetts, is one of the largest museums in the United States. It contains more than 450,000 works of art, making it one of the most comprehensive collections in the Americas. With more than one million visitors a year, it is (as of 2013) the 62nd most-visited art museum in the world.\n\nFounded in 1870, the museum moved to its current location in 1909. The museum is affiliated with an art academy, the School of the Museum of Fine Arts, and a sister museum, the Nagoya/Boston Museum of Fine Arts, in Nagoya, Japan. The director of the museum is Malcolm Rogers.","image":"http://www.mfa.org/sites/default/files/imagecache/showcase_2/images/Fenway%20at%20dusk_0.jpg","latitude":42.3394675,"longitude":-71.0948962,"address":null,"hours":null}}
```

### Unsuccessful Response

Response Code: 500?
