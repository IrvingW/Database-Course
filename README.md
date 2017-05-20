# Cinema management system
A design project for database course in SJTU. \
This project designs a database for a cinema management system
<br>
## Group member
[Qian Xinxin]()\
[Wang Tao](https://github.com/IrvingW)\
[Zhao Mingxin]()

## Detail
### Function Describe
This system includes some functions as follows:
* Server can make a movie show plan waiting for manager's approvement.
* Plans approved by manager will provided to customers to choose.
* Customers could buy any amount of tickets for different plans or for different seats in 
  one order as long as those seats are avaliable.
* Customers can sign up as a VIP in this cinema, whose infomations will be stored in the system.
* VIP customers could apply for vip cards which need to be activated.
* Vip customers could pause, recover, activate or cancel their card.
* vip card could been used as a value card. A VIP customer could charge for his card.
  The money will be used to buy movie tickets.
* VIP customers could buy different rank VIP for different span using different money.
* VIP customers will aquire different discounts when buy movie tickets acrodding to their VIP rank.
* VIP customers with a card could get points by buying movie tickets, which could used to exchange some prizes.
* Different prizes need different points and rank. 
* VIP customer could pay for orders using whether vip cards or cash. 

### Conceptual Modle
![Picture](https://github.com/IrvingW/Database-Course/blob/master/Conceptual%20Model.png)
<br>

### Relational Database
![Picture](https://github.com/IrvingW/Database-Course/blob/master/Relational%20Database.png)
<br>

## Deploy
You can use the mysql script deploy_database.sql to install the database, 
then run the procedure&trigger.sql script file to create our procedure and tirgger.
Finally, the file test.sql provides some test code to test our database. You can use it follow the comments.
