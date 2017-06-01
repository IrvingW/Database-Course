use cinema;
DELIMITER $$


#插入新的注册记录，自动生成一张未激活（-1）的vip卡alter
drop procedure if exists sign_up_pro;$$

create procedure sign_up_pro(in client_id integer,in time timestamp)
begin
	declare card integer;
	insert into vip_card(level_id, remain_time, point, state, remain_money) 
		values(0, 0, 0, -1, 0);
	select max(card_id) into card from vip_card;
	insert into sign_up values(card, client_id, time);
end$$



#插入新的续费记录时
#检查当前会员卡的状态 
drop trigger if exists level_update;$$
CREATE TRIGGER level_update before INSERT ON charge_record
FOR EACH ROW
BEGIN 
declare card_state integer;
declare level integer;
declare days integer;
select state into card_state from vip_card where card_id = new.card_id;
if card_state = 0
then
	select level_id into level from vip_card where card_id = new.card_id;
	if 
		level = new.level_id
	then 
		update vip_card set remain_time = (remain_time + new.pay_for_days)
		where card_id=new.card_id;
	else
		UPDATE vip_card
		SET level_id=new.level_id,remain_time=new.pay_for_days
		WHERE card_id=new.card_id;
	end if;
else 
	SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = "会员卡不在激活状态.";
end if;
END $$



#时间每天减一的procedure
drop procedure if exists time_reduce;$$
create    procedure   time_reduce ()     
     READS SQL DATA 
 begin
UPDATE vip_card
SET remain_time=remain_time-1
WHERE (remain_time>0) and state=0;
end$$



#每天定时执行的job
drop event if exists remain_time_change;$$

Create event remain_time_change
On schedule 
Every 1 day

Do
Begin
Call time_reduce();
END$$ 


# 用户改变状态的trigger
drop trigger if exists change_state;$$
create trigger change_state after insert on state_change_record
for each row 
begin 
	update VIP_card set state = new.modify_state
    where VIP_card.card_id = new.card_id;
end$$



# 兑换积分 
# check if points are enough
drop trigger if exists exchange_point;
$$
create trigger exchange_point before insert on exchange_record
for each row
begin
	declare need_point integer;
    declare have_point integer;
    declare have_rank integer;
    declare need_rank integer;
    select points_need into need_point from prize where prize_id = new.prize_id;
    select point into have_point from vip_card where card_id = new.card_id;
    select level_id into have_rank from vip_card where card_id = new.card_id;
    select level_need into need_rank from prize where prize_id = new.prize_id;
    
    if(have_rank < need_rank) 
    then 
        SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = "当前等级尚未满足";
	else
		if(have_point >= need_point)
		then
			update VIP_card set point = (VIP_card.point - need_point) where VIP_card.card_id = new.card_id;
		else
			SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = "用户积分不足.";
		end if;
	end if;
end$$


## used by cal_discount
drop procedure if exists update_seat_proc;$$ 
create procedure update_seat_proc(in id integer)
begin
	declare plan integer;
    declare count integer;
	declare stop int default 0;
    declare cur cursor for (select plan_id,count(*) as count from order_item where order_id = id group by plan_id);
    declare CONTINUE HANDLER FOR SQLSTATE '02000' SET stop=1;
    
	OPEN cur;
    read_loop: LOOP
		FETCH cur INTO plan,count;
		IF stop = 1 then
			LEAVE read_loop;
		else
			update plan set seat_remain = (seat_remain - count) where plan_id = plan;
        end if;
	END LOOP;
  CLOSE cur;
END$$


#首先插入一个总价和积分都为零的order，此时order——item已有，再去计算实际的总价和积分。 
#drop procedure cal_discount;
drop procedure if exists cal_discount;$$
create procedure cal_discount(in id integer)
begin 
declare price_sum integer;
declare point_sum integer; 
declare disc integer;
declare real_price integer;
declare have_money integer;
declare card integer;


select card_id into card from order_record where order_id = id;

select sum(price*count),sum(point_to_get*count) into price_sum,point_sum
	from (plan natural join (select plan_id,count(*) as count from order_item where order_id = id group by plan_id) as temp) ;

select discount into disc from level_detail 
	where level_id = (select level_id from VIP_card where card_id=card);
        
set real_price=price_sum * disc / 100;


# check buy way
if ((select buy_way from order_record where order_id = id) = 0)
then
	select remain_money into have_money from vip_card where card_id = card;
	
    if (have_money >= real_price)
    then
		update VIP_card set remain_money = (remain_money - real_price) where card_id = card;
		call update_seat_proc(id);
    else
        SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = "卡内余额不足";
	end if;
end if;

update order_record set real_tot_price = real_price where order_id = id;
update order_record set point_get = point_sum where order_id = id;
update VIP_card set point = (point + point_sum) where card_id = card;

end$$



# 向卡里充值, 插入一条充值记录,立刻去修改card里的相关项.
drop trigger if exists add_money;$$
create trigger add_money after insert on add_money_record
for each row
begin
	update VIP_card set remain_money = (remain_money + new.add_amount) 
		where card_id = new.card_id;
end$$

