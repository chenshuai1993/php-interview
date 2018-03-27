<?php
/**
 * Created by PhpStorm.
 * User: chen
 * Date: 2018/3/27
 * Time: 下午2:54
 */

//字符串翻转
//原理: 字符串可以数组式的访问 $str[1];


$str = 'chenshuai';
function _strrev($str)
{
    $strrev = '';
    $len = strlen($str);

    //判断
    if($len == 1) return $str;

    for ($i=$len-1; $i>=0; $i--){
        $strrev .= $str[$i];
    }

    return $strrev;
}


echo _strrev($str);