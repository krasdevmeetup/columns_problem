<?php

  $data = json_decode(file_get_contents('source_array_json.txt'));

  $heights = array();
  foreach($data as $k=>$v){
    $heights[$k] = 36;
    if (is_array($v->children))
      foreach($v->children as $kk=>$vv){
        $heights[$k] += 24;
        if (is_array($vv->children))
          foreach($vv->children as $kkk=>$vvv){
            $heights[$k] += 12;
          }
      }
  }

  $column_height_perfect = ceil( array_sum($heights) / 3 );
  $category_height_medium = ceil( array_sum($heights) / count($heights) );

  $sigma = array();
  foreach($heights as $k=>$v){
    $sigma[$k] = $v - $category_height_medium;
  }
  arsort($sigma);
  $sigma_keys = array_keys($sigma);
  
  $columns = array();
  $column_index = 0;
  $column_height = 0;
  $gap = 50;
  $use_top = TRUE;

  foreach($sigma_keys as $k=>$v){
    if ($use_top){
      $key = $columns[$column_index][] = array_shift($sigma_keys); 
    }
    else{
      $key = $columns[$column_index][] = array_pop($sigma_keys); 
    }
    $column_height += $heights[$key];
    $use_top = !$use_top;
    if ($column_height >= $column_height_perfect - $gap && $column_index < 2){
      $column_index++;
      $column_height = 0;
    }
  }
?>
<style>
<!--
table {border: 1px solid red; width: 100%; border-collapse: collapse}
table td {vertical-align: top; border: 1px solid red; padding: 10px}
table td h1 {height: 36px; margin: 0; line-height: 36px; font-size: 30px; background: #ccc}
table td h2 {height: 24px; margin: 0; line-height: 24px; font-size: 20px; background: #aaa}
table td h3 {height: 12px; margin: 0; line-height: 12px; font-size: 10px; background: #888}
-->
</style>  
  <table><tr>
  <?php foreach($columns as $k=>$v): ?>
    <td >
    <?php foreach($v as $category_index): ?>
      <h1><?=$data[$category_index]->name; ?></h1>
      <?php if (is_array($data[$category_index]->children)): ?>
        <?php foreach($data[$category_index]->children as $i_1 => $subcategory_1): ?>
          <h2><?=$subcategory_1->name?></h2>
          <?php if (is_array($data[$category_index]->children[$i_1]->children)): ?>
            <?php foreach($data[$category_index]->children[$i_1]->children as $subcategory_2): ?>
              <h3><?=$subcategory_2->name?></h3>
            <?php endforeach?>
          <?php endif ?>
        <?php endforeach?>
      <?php endif ?>
    <?php endforeach?>
    </td>
    <?php endforeach?>
  </tr></table>
  