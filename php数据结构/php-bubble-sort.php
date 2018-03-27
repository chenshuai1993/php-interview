<?php
/**
 * Created by PhpStorm.
 * User: chen
 * Date: 2018/3/27
 * Time: 上午10:39
 */

//冒泡排序
//双重循环, 外层控制循环次数, 内层控制比较次数
//时间复杂度 O(n^2)
//
//思路整理
//一个长度为N的数组,进行冒泡排序,
//需要进行 N-1 次循环,
//每 i 次循环, 需要对比 N-i 次数据,
//结论:  每第 i 次循环   +  对比 N-i 次  == 常数  N == 数组长度
//参考 https://www.cnblogs.com/wgq123/p/6529450.html






$array = [2,10,3,8,5];


function bubble_sort($array)
{
    //要循环的次数  N-1
    $count = count($array)-1;

    //双重循环
    //循环次数
    for($i=0; $i<$count; $i++){

        //对比次数
        for($j=0; $j<$count-$i; $j++)
        {
            if($array[$j] > $array[$j+1]){
                //调换位置
                $temp = $array[$j];
                $array[$j]      = $array[$j+1];
                $array[$j+1]    = $temp;


            }
        }
    }

    return $array;
}


print_r(bubble_sort($array));
exit;