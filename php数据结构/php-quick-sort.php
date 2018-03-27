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


//快速排序的原理: 当数组中的任意元素(一般选择第一个元素),作为标准,新建2个数组, 遍历整个数组,比标准小的放在左边，比标准大的放在右边
//然后对新数组进行同样的操作
//不难发现，这里符合递归的原理，一般阶梯都是用递归实现

//递归点： 如果数组的元素大于1，那么就需要在进行分解，所以我们的递归点是新构造的数组元素个数大于 1
//递归出口: 当数组元素个数变成1 或 小于1的时候，这就是我们的出口

$array = [10,3,5,14,38];



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

        # print_r(array_merge($left,array($compare),$right));
        #echo PHP_EOL;
        return array_merge($left,array($compare),$right);
    }else{
        #print_r($array);
        #echo PHP_EOL;
        return $array;
    }

}


//打印过程如下,便于理解


/*
 *
        一次调用               10 3 5 14 38
                               mid  10
          2次        left [3,5]                    [14,38]  right
                        mid 3                   mid 14
            3次  left [] , 4次  [5] right        left[],   [38] right
                return[],        reutrn [5]      return [],  return [38]
                   merge([],3[5])                mergr([],[14],[38])

                    mergr([3,5],[10],[14,18])


Array
(
)

Array
(
    [0] => 5
)

Array
(
    [0] => 3
    [1] => 5
)

Array
(
)

Array
(
    [0] => 38
)

Array
(
    [0] => 14
    [1] => 38
)

Array
(
    [0] => 3
    [1] => 5
    [2] => 10
    [3] => 14
    [4] => 38
)

Array
(
    [0] => 3
    [1] => 5
    [2] => 10
    [3] => 14
    [4] => 38
)*/

