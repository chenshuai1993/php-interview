<?php
/**
 * Created by PhpStorm.
 * User: chen
 * Date: 2018/3/26
 * Time: 下午6:43
 */

//php快速排序
//理论: 找到数组的第一个值， 然后依次跟数组后面的值（第一个元素之后的值）进行比较,
//      如果比第一个值小  那么就放在 left 这个数组中, 如果比第一个大 那么久放在右边
//      递归比较,知道ok


$array = [10,3,5,14,38,4,67,9,1,88];


$list = quick_sort($array);
print_r($list);
die;

function quick_sort($array)
{

    if(count($array) > 1){
        $compare = $array[0];
        $left = [];
        $right= [];
        $count = count($array);

        for ($i=1;$i<$count;$i++){
            if($array[$i] <= $compare){
                $left[] = $array[$i];
            }else{
                $right[] = $array[$i];
            }
        }

        $left = quick_sort($left);
        $right = quick_sort($right);

        return array_merge($left,array($compare),$right);
    }else{
        return $array;
    }

}


