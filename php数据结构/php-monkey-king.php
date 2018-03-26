<?php
/**
 * Created by PhpStorm.
 * User: chenshuai
 * Date: 2018/3/26
 * Time: 下午2:10
 */

/**
 * 循环单链表的目的,就是来解决约瑟夫环的问题
 * 就单独解决约舍夫环的问题,可以用堆栈，也可以用循环单链表
 */




##堆栈
function monkeyKing($range,$king)
{
    $list = range(1,$range);
    $i = 0;
    //选一个king
    while (count($list) > 1){

        ++$i;

        //先都出栈
        $shift = array_shift($list);

        //不符和数字要求
        if($i % $king <> 0){
            //入栈
            array_push($list,$shift);
        }

    }

    return $list[0];
}
print_r(monkeyKing(10,3));



