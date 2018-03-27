<?php
/**
 * Created by PhpStorm.
 * User: chen
 * Date: 2018/3/27
 * Time: 上午11:36
 */

//php 选择排序

$array = [1,10,5,38,8];

//原理： 在一列数字中，选出最小数(首次是第一个)与第一个位置的数交换。然后在剩下的数当中再找最小的与第二个位置的数交换，如此循环到倒数第二个数和最后一个数比较为止。(以下都是升序排列，即从小到大排列)


function select_sort($array)
{
    //排序次数
    $count = count($array);
    $temp = 0;
    //循环次数
    for ($i = 0; $i<$count-1; $i++){

        //设置最小的索引
        $minIndex = $i;
        //比较次数
        for ($j=$i+1; $j<$count; $j++){

            //正序比较
            if($array[$j] < $array[$minIndex]){
                //最小的索引更改
               $minIndex = $j;
            }
        }

        if($i != $minIndex){
            $temp = $array[$i];
            $array[$i] =$array[$minIndex];
            $array[$minIndex] = $temp;
        }


    }

    return $array;



}

function order($arr){
    //定义中间变量
    $temp = 0;
    $count = count($arr);
    for($i=0; $i<$count-1; $i++){
        //定义最小位置
        $minIndex = $i;
        for($j= $i+1; $j<$count; $j++){
            if($arr[$j] < $arr[$minIndex]){
                $minIndex = $j;
            }
        }
        if($i != $minIndex){
            $temp = $arr[$i];
            $arr[$i] = $arr[$minIndex];
            $arr[$minIndex] = $temp;

        }
    }
    return $arr;

}


print_r(select_sort($array));die;