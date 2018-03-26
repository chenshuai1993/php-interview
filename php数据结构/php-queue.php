<?php
/**
 * Created by PhpStorm.
 * User: chen
 * Date: 2018/3/26
 * Time: 下午4:15
 */

//队列 是特殊化的单链表  先进先出LILO
//队列 只允许在一方插入  和 另一方删除


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

//队列 == 特殊化的单链表
//尾插头删
/*class queue
{
    public $head;
    public $size;

    //尾插
    public function add($node)
    {
        if($this->size == 0){
            $this->head = $node;
        }else{
            $curr = $this->head;

            while (1){
                if($curr->next == null){
                    $curr->next = $node;
                    break;
                }
                $curr = $curr->next;
            }
        }

        $this->size++;
    }


    //头删
    public function del()
    {
        $this->head = $this->head->next;
        $this->size--;
    }
}*/



//头插尾删
class queue
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


    //尾删
    public function del()
    {
        $curr = $this->head;
        if($this->size == 1){
            $this->head = new node();
            $this->size = 0;
        }else{
            while (1){
                if($curr->next->next == null){
                    $curr->next = null;
                    $this->size--;
                    break;
                }
                $curr = $curr->next;
            }
        }

    }
}


$node1 = new node('1','chenshuai');
$node2 = new node('2','chenshuai2');
$node3 = new node('3','chenshuai3');
$node4 = new node('4','chenshuai4');




$queue = new queue();


//队列默认尾插法
$queue->add($node1);
$queue->add($node2);
$queue->add($node3);
$queue->add($node4);


//删除默认头插法删除
$queue->del();
$queue->del();
#$queue->del();
#$queue->del();



print_r($queue);