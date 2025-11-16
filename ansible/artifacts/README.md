# FULL STACK APP WITH NODEJS, EXPRESS, SEQUELIZE ORM, MYSQL, REACT

# Commands to Backend with Nodejs + Express + Sequelize
1. npm init -y 
2. npm i express cors mysql2 sequelize
3. npm i nodemon --save-dev  -->  nodemon app

# Commands to Frontend with React

1. Npx create-react-app frontend  --->   npm start
2. npm install axios react-router-dom
3. npm i bootstrap



# My_SQL setup
``` sql
create database crud_react_node;
use crud_react_node;

CREATE TABLE blogs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

```
