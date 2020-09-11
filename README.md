# Drover BackEnd test (On Going...)

This is my submission for the Back-End Take Home Challenge by Drover. The exercise documentation can e find here: <https://github.com/DroverLtd/code-challenge-be>

You can find my solution live here: <https://drover-api.herokuapp.com/cars>

## Inicial Set Up

To facilitate the installation process, I've used docker and will present the steps to have the project running locally for testing. The first step is to clone the project to your machine and you can do this by running the presented line on the terminal.

```git clone https://github.com/pedromartinho/drover-api```

After that, you can build the database and app container by running

```docker-compose build```

This will build the docker images and you can run them, by executing the following line:

```docker-compose up -d```

Now that both imaged are up and running, we need to go inside the app container and create the database. To do so, you can run ```docker ps```, take the app container id and run the following line:

```docker exec -it <container_id> /bin/bash```

Now you are inside the app container and we need to create the database and the respective migrations to have

```run rails db:create db:migrate```

After that, you can write the presented script to generate **234 cars**, **3 brands**, **6 models** and **9 colors** (3 colors per brand).

```run rails populate:makers_colors_models```
```run rails populate:cars```

If you have problems performing this steps, do not hesitate contact me or you can find the live application on <https://drover-api.herokuapp.com/cars>.

## Peoject Description

### Database

In this exercise I have to consider the following specifications for each car:

* Maker
* Model
* Year
* Color
* Subscription Price
* Available from

Given this information, the ER Model we have created is the following:

![picture alt](https://teste-martinho-page.s3-eu-west-1.amazonaws.com/share/drover_db.png "ER Model - Drover")

### Endpoints

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

### Deployment

I've taken the liberty to deploy my solution on heroku in order to make it easier to test since you do not have to follow the set up process

## Final notes

Really enjoy doing this challenge! Hope you consider my solution appropriate. If there is any problem in the test process our there's any doubt I can clarify, just let me know.
Hope to be part of the team soon. Looking foward for the next meeting.
