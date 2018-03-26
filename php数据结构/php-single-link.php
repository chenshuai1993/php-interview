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

    /**
     * @param node $node
     * @param int $preNodeId
     * @return $this 链式增加
     */
    public function add(node $node, int $preNodeId = 0)
    {
        ##循环

        #空链表 直接头插
        if($this->size == 0) {

            $this->head = $node;

        } elseif ($preNodeId == 0) {

            //如果不是空链表 并且没有指定前置节点id,默认的话,链表头插
            $node->next =  $this->head;  //当前node的next 指向 $this->head
            $this->head =  $node;        //当前node 设置为单链表头

        } elseif($preNodeId != 0) {

            //不是空链表,并且设置了前置节点id
            $curr = $this->head;

            while ($curr->next != null)
            {
                if($curr->next->id == $preNodeId){  //当前节点的下一个节点id == 要查找的前置节点
                    $node->next = $curr->next;
                    $curr->next = $node;
                    break;
                }
                $curr = $curr->next; //没有匹配到前置节点， 那么就下一个,which在进行下一次判断
            }

        }

        $this->size++;

        return $this;
    }

    /**
     * @删除单链表元素
     * @param $index
     * @return bool
     */
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


    /**
     * @获取单链表的元素
     * @param $index
     * @return $node
     */
    public function get($index)
    {
        $curr = $this->head;

        $node = [];
        while ($curr->id != null){
            if($curr->id == $index){
                $node = $curr;
                break;
            }
            $curr = $curr->next;
        }

        return $node;

    }


    /**
     * @编辑单链表
     * @param $index
     * @param $val
     * @return bool
     */
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
$list->add($node1)->add($node2)->add($node3)->add($node4);


#删除
#$list->del(3);
#$list->del(2);

#改
#$list->edit(3,'3333');

#查
#print_r($list->get(3));

#print_r($node1);
#print_r($node2);
print_r($list);