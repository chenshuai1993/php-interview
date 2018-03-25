<?php
/**
 * Created by PhpStorm.
 * User: chenshuai
 * Date: 2018/3/24
 * Time: 下午8:19
 */

##单链表 头插示例

#节点对象
class node
{
    public $id = 0;
    public $data;
    public $next = null;

    public function __construct($index,$value)
    {
        $this->id  = $index;
        $this->data= $value;
    }

}




//单链表对象
class singleLink
{

    public $head;

    public $size;


    public function add(node $node)
    {
        //循环
        if($this->size == 0){
            $this->head = $node;
        }else{
            //单链表 头插
            $node->next =  $this->head; //当前node的next 指向 $this->head->id
            $this->head =  $node;        //当前node 设置为单链表头
        }

        $this->size++;

    }

    public function del($index)
    {
        //循环
        $flag = false;
        $curr = $this->head;
        while ($curr->id != null){

            if($curr->next->id == $index){

                $curr->next = $curr->next->next; //当前元素的下一个元素 指向 孙辈元素
                $this->size--;
                $flag = true;
                break;
            }

            $curr = $curr->next;
        }


        return $flag;

    }


    //头插
    public function get($index)
    {
        $curr = $this->head;

        while ($curr->id != null){
            if($curr->id == $index){
                $node = $curr;
                return $node;
                break;
            }
            $curr = $curr->next;
        }


    }


    public function edit($index,$val)
    {
        $curr = $this->head;
        $flag = false;
        while ($curr->id != null){
            if($curr->id == $index){
                $curr->data = $val;
                $flag = true;
                break;
            }
            $curr = $curr->next;
        }

        return $flag;
    }



}

//node  index,data

$node1 = new node(1,'chenshuai');
$node2 = new node(2,'liuxue');
$node3 = new node(3,'shanshan');
$node4 = new node(4,'shanshan4');



$list = new singleLink();


#增加
$list->add($node1);
$list->add($node2);
$list->add($node3);
$list->add($node4);


#删除
#$list->del(3);
#$list->del(2);

#改
#$list->edit(3,'3333');

#查
#print_r($list->get(4));

#print_r($node1);
#print_r($node2);
print_r($list);