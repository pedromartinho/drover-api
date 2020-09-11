# Drover Back-End Take Home Challenge

This is my submission for the Back-End Take Home Challenge by Drover. The exercise documentation can e find here: <https://github.com/DroverLtd/code-challenge-be>

You can find my solution live here: <https://drover-api.herokuapp.com/cars>

## Initial Setup

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

After that, you can write the presented script to generate **234 cars**, **3 brands**, **6 models** and **9 colors** (3 colors per brand). The **populate:cars** creates 234 cars, 13 for each model and color combination

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

![picture alt](https://teste-martinho-page.s3-eu-west-1.amazonaws.com/share/new_er.png "ER Model - Drover")

### Endpoints

I've to build 3 different endpoints:

* **GET /cars** | index
* **POST /cars** | create
* **PUT /cars/:car_id** | update

Each of the endpoints will have multiple validations explained in the next topics. For test purposes, I've created a postman collection (**drover_api.postman_collection.json**) that I've inserted in the repo. If you want to quickly test the application, you can import it into Postman and test it. The only thing that might need to be changed is the api variable that can be changed if you edit the collection itself.

#### POST /cars | create

The POST endpoint will be used for the creation of new cars. This endpoint receives a json object in the request body and will lead to the creation of a car in the database. Here's an example of a valid object for a car creation.

```{ "model_id": 1, "color_id": 1, "license_plate": "AA-03-00", "available_from": "2022-02-11", "price": 100, "year": 2020 }```

If any of the given fields is missing, you'll get a 400 status code, since all the fields are needed for the creation of a car.

Regarding the **model_id**, it is verified if the given id corresponds to a entry in the database. The same validation applies to the **color_id** and it is also verified if the color and model combination is compatible. If the model or color are not in the database, a 404 status code will be returned.

The **license_plate** input must respect one of the following formats 'AA-00-00', '00-AA-00' or '00-00-AA' and will give an error otherwise.

The **available_from** input must have the format 'YY-mm-dd' and cannot be lower than the current day.

The **price** simply must be a positive number and the **year** must be between 1886 (birth year of the modern car) and 2020.

All the errors will be have an error message to help understand what might be wrong with the request.

In case of success, the response will return the new car information:

```{ "message": "Car AA-13-00 created!", "car": { "id": 471, "license_plate": "AA-13-00", "year": 2020, "available_from": "2022-02-11", "color_name": "Alpine White", "model_name": "Series3", "maker_name": "BMW"} }```

#### GET /cars | index

The GET endpoint will be used to list all the available cars. Since it is a GET method, all the considered params are query params and are the following:

* limit
* page
* min_months
* sort
* field
* maker_id
* color_id

If no **limit** is given, it will consider 20 by default. If no **page** is give, it will consider 1 by default. Both of this values must be positive numbers.

The **min_months** parameter is a threshold that is set to 3 by default: if the available date has more than 3 months of the current date, it will be filtered. I've given the change to filter this parameter since my script creates 18 cars that are **currently available (available_from = null)** and the other 216 cars are only available on '2021-01-01' ou later.

By default, all the results are ordered by the price in ascending order. The **sort** param accepts the values 'descend' and 'ascend' to sort the results. You can also chose with **field** you want to order: available_from price year maker_n.

Finally, you can filter the results base on the **maker_id** or **color_id**.

I've chose to use the **find_by_sql** method since it allows to get the information must faster when you have information from the main object in different tables. If the number of objects per page is bigger, like 100, the difference in terms of performance significant.

I've also taken the liberty to add to the index response the array of **models**, **colors** and **makers** that I've created in the database. You can also find the **total** number of objects that meet the filter conditions.

You can find an example of and object in the cars array

```{ "id": 379, "license_plate": "11-SR-51", "available_from": "2021-01-01", "price": "301.0", "year": 2017, "color_n": "Silver Metallic", "model_n": "RAV4", "maker_n": "Toyota" }```

#### PUT /cars/:car_id | update

The PUT endpoint will be used for the update a given car, specified as a path param **car_id**. The validations are the same as in the create endpoint. What changes is the fact that you only need to send one of the parameters to be changed. If no expected parameter is sent, it will give an 400 status code error.

The returned object has the same format as the one returned in the create endpoint.

### Deployment

I've taken the liberty to deploy my solution on heroku in order to make it easier to test since you do not have to follow the setup process.

## Final notes

Really enjoy doing this challenge! Hope you consider my solution appropriate. If there is any problem in the test process our there's any doubt I can clarify, just let me know.

Hope to be part of the team soon. Looking forward for the next meeting.
