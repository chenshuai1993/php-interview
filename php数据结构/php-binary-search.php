<?php
/**
 * Created by PhpStorm.
 * User: chen
 * Date: 2018/3/26
 * Time: 下午6:02
 */

//php二分查找
//根据数组下标来进行排序

$arr = [4,6,7,11,13,16,20,25];
$search = 7;


function binart_search(array $arr,int $search)
{

    $low = 0;
    $high =count($arr)-1;

    while ($high >= $low){ //条件是 数组中高下标一直在减少，  数组中小的下标一直在增加
        $mid = intval(($low+$high)/2); //数组中间的下标 向下取整

        if($search == $arr[$mid]){
            echo  $mid; //返回下标
            break;
        }

        if($search > $arr[$mid]){ //在后半部分,那么 low 增加,
            $low = $mid +1; //比mid下标 大一位
        }else if($search < $arr[$mid]){  //
            $high = $mid - 1; //比mid下标小一位
        }
    }
}



binart_search($arr,20);