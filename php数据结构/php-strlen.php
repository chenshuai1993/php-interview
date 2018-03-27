<?php
/**
 * Created by PhpStorm.
 * User: chen
 * Date: 2018/3/27
 * Time: 下午2:49
 */

//不用系统方法 实现strlen函数
//原理是: 字符串可以用数组的方式访问

$str = 'chenshuai';
function _strlen($str){
    $len = 0;

    //isset 系统结构  小笼包
    while (isset($str[$len])){
        $len++;
    }

    return $len;
}


echo _strlen($str);