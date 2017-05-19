
use cinema;
#level detail insert
	# for one month
insert into level_detail values(0,0,"None");
    
insert into level_detail values(80,1,"Gold");
insert into level_charge values(1, 30, 50);
insert into level_charge values(1, 60, 80);
insert into level_charge values(1, 90, 120);

insert into level_detail values(85,2,"Silver");
insert into level_charge values(2, 30, 40);
insert into level_charge values(2, 60, 70);
insert into level_charge values(2, 90, 100);

insert into level_detail values(90,3,"Bronze");
insert into level_charge values(3, 30, 30);
insert into level_charge values(3, 60, 55);
insert into level_charge values(3, 90, 80);

 
#prize
insert into prize(level_need, prize_name, points_need) values(0, "画饼一张",10);
insert into prize(level_need, prize_name, points_need) values(0, "白拿奖",0);
insert into prize(level_need, prize_name, points_need) values(0, "积分永远不够的奖",1000);
insert into prize(level_need, prize_name, points_need) values(5, "等级永远不够的奖",0);


#manager
insert into manager(manager_password, manager_name) values("IAmManager","Tom");

#server
insert into server(server_password,server_name) values("IAmServer","Jerry");


#plan
#plan state: 1 for approved, 0 for not
insert into plan(server_id, manager_id,start_time,movie_name,room_id,seat_remain,price,point_to_get,span,plan_state)
	values(1,1,20170512040911,"Avengers",1,100,3000,1,1.5,1);
insert into plan(server_id, manager_id,start_time,movie_name,room_id,seat_remain,price,point_to_get,span,plan_state)
	values(1,1,20170512040911,"Avengers 2",2,100,3000,1,1.5,1);
    # 30 yuan
#check

# vip 
insert into vip values(10083, "Irving", null, null);
insert into vip values(10084, "Naivee", null, null);
insert into vip values(10085, "Mingxin", null, null);


select * from vip;
select * from level_charge natural join level_detail;
select * from prize;
select * from manager;
select * from server;
select * from plan;

######################################################################################

## 注册 
# state: -1 未激活，0 激活，1 暂停， 2 停止  
# sign up record insert
# create three card atomically, state = -1 (have not activated)
# insert three users

select * from vip_card;
call sign_up_pro(10083, 20170312040911);
call sign_up_pro(10084, 20170312041012);
call sign_up_pro(10085, 20170312042312);
# check 
select * from sign_up;
select * from vip_card;


## 充会员 
# test if user can charge before activate card
# 尚未激活
insert into charge_record values(1,20170412040911,3,30);  # 30
select * from charge_record;

#insert change_state_record
# state: -1 未激活，0 激活，1 暂停， 2 停止
# 激活3张卡  
insert into state_change_record values(1, 20170412040911, 0);
insert into state_change_record values(2, 20170412040911, 0);
insert into state_change_record values(3, 20170412040911, 0);
select * from vip_card;

#charge for rank
#charge 30 days for different rank for each card

#激活后再次尝试冲会员 
insert into charge_record values(1,20170312040911,1,30); 
insert into charge_record values(2,20170312040911,2,30); 
insert into charge_record values(3,20170312040911,3,30); 
select * from vip_card; # three records


## 兑换奖品 
# check point check 
# 积分不足
insert into exchange_record values(1, 3, 20170312040912); 
select * from exchange_record; # do not insert


# check level check 
# 等级不足
insert into exchange_record values(1, 4, 20170312040911); 
select * from exchange_record; # do not insert
# check exchange

select * from prize;
insert into exchange_record values(1, 2, 20170312040911);
select * from exchange_record; # insert success


## 充值 
# add money
select * from vip_card;
insert into add_money_record values(1,20170412050514,10000); #100 
insert into add_money_record values(2,20170412050511,0);
insert into add_money_record values(3,20170412050511,10000); # 20
select * from vip_card;


## 购票
# buy way, 0 for card , 1 for cash
select * from order_record;
select * from order_item;
insert into order_record(buy_time,real_tot_price,buy_way,card_id,point_get)values(20170501020202,0,0,1,0); # by card 1
insert into order_item(order_id,plan_id,seat)values(1,1,1);
insert into order_item(order_id,plan_id,seat)values(1,1,2);
insert into order_item(order_id,plan_id,seat)values(1,2,1);

select remain_money,point from vip_card where card_id = 1;
select seat_remain from plan;

call cal_discount(1);

select remain_money,point from vip_card where card_id = 1;
select seat_remain from plan;


# check remain_money check
# 卡内余额不足 
insert into order_record(buy_time,real_tot_price,buy_way,card_id,point_get)values(20170501020202,0,0,2,0);
insert into order_item(order_id,plan_id,seat)values(2,1,5);
select remain_money,point from vip_card where card_id = 2;
call cal_discount(2);


# buy ticket by cash
insert into order_record(buy_time,real_tot_price,buy_way,card_id,point_get)values(20170501020202,0,1,3,0); # by cash
insert into order_item(order_id,plan_id,seat)values(3,1,2);
insert into order_item(order_id,plan_id,seat)values(3,1,3);
insert into order_item(order_id,plan_id,seat)values(3,1,4);
select remain_money from vip_card where card_id = 3;
call cal_discount(3);
select remain_money from vip_card where card_id = 3;


# check modify point in vip_card
select * from vip_card;
insert into exchange_record values(1, 1, 20170312040911);
select * from vip_card;