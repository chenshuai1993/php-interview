<?php
/**
 * Created by PhpStorm.
 * User: chen
 * Date: 2018/3/26
 * Time: 下午4:18
 */

//栈是特殊化的单链表   头插和头删  类似弹夹


//节点
class node{
    public $index;
    public $data;
    public $next=null;

    public function __construct($index='',$value='')
    {
        $this->index = $index;
        $this->data  = $value;
    }
}


class stack
{
    public $head;
    public $size;

    //头插
    public function add($node)
    {
        if($this->size == 0){
            $this->head = $node;
        }else{
            $node->next = $this->head;
            $this->head = $node;
        }
        $this->size++;
    }


    //头删
    public function del()
    {
        $this->head = $this->head->next;
        $this->size--;
    }
}



$node1 = new node('1','chenshuai');
$node2 = new node('2','chenshuai2');
$node3 = new node('3','chenshuai3');
$node4 = new node('4','chenshuai4');




$queue = new stack();


//栈默认头插法
$queue->add($node1);
$queue->add($node2);
$queue->add($node3);
$queue->add($node4);

//栈头删
$queue->del();
$queue->del();
$queue->del();
$queue->del();

#$queue->add($node1);

print_r($queue);