# Drover BackEnd test
This is my submission for the Back-End Take Home Challenge by Drover. The excercise documentation can e find here: https://github.com/DroverLtd/code-challenge-be

You can find my solution live here: https://drover-api.herokuapp.com/cars 

## Database
In this exercise I have to consider the following specifications for each car:
* Maker
* Model
* Year
* Color
* Subscription Price
* Available from

Given this information, the ER Model we have created is the following:

![picture alt](https://teste-martinho-page.s3-eu-west-1.amazonaws.com/share/sample.png "ER Model - Drover")

## Endpoints
I've to build 3 different endpoints:
* **POST /cars** | create
* **GET /cars** | index
* **PUT /cars/:car_id** | update

Each of the endpoints will have multiple validations explained in detail in the next topics.

#### POST /cars | create
The POST endpoint will be used for the creation of new cars

#### GET /cars | index
The GET endpoint will be used to list all the available cars. Since it is a GET method, all the considered params are query params and are the following:
* limit
* page
* sort
* field
* maker
* color

If no **limit** is given, it will consider 10 by default. If no **page** is give, it will consider 1 by default.

#### PUT /cars/:car_id | update
The PUT endpoint will be used for the creation of new cars

## Deployment
I've taken the liberty to deploy my solution on heroku in order to make it easier to test since you do not have to follow the set up process

## Final notes
Really enjoy doing this challenge! Hope you consider my solution appropriate. If there is any problem in the test process our there's any doubt I can clarify, just let me know.
Hope to be part of the team soon. Looking foward for the next meeting.
