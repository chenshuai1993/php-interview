<?php
/**
 * Created by PhpStorm.
 * User: chenshuai
 * Date: 2018/4/15
 * Time: 下午4:29
 */

$array = [12,15,7,1,13];

function quick($array){



    //退出条件
    if(count($array) <= 1){
        return $array;
    }




    $head = $array[0];
    $left = [];
    $right= [];

    //modify
    $count = count($array);

    /*foreach ($array as $key => $value){

        if($value > $head){
            $left[] = $value;
        }else{
            $right[] = $value;
        }

    }*/


    for($i=1;$i<$count;$i++){
        if($array[$i] > $head){
            $left[] = $array[$i];
        }else{
            $right[] = $array[$i];
        }
    }





    $left = quick($left);
    $right = quick($right);


    return array_merge($left,[$head],$right);
    //print_r($result);

}

print_r(quick($array));