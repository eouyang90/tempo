(function() { this.JST || (this.JST = {}); this.JST["backbone/templates/activities/customActivity"] = function(obj){var __p=[],print=function(){__p.push.apply(__p,arguments);};with(obj||{}){__p.push('<!-- Temporary styling -->\n<!-- TODO: move this away -->\n\n<div class="customActivity">\n\t<header> \n\t\t<h4 id=\'customActivityTitle\' style=\'color: #9b59b6;\'> Custom Activity List for ',  name,' </h4> \n\t</header>\n\t<br>\n\t<table class=\'customActivityTable\' >\n\t\t<thead>\n\t\t\t<tr>\n\t\t\t\t<th>Title</th> <th>Content</th> <th>Time</th> <th>Delete</th>\n\t\t\t\t<!-- <th colspan=\'3\'> </th> -->\n\t\t\t</tr>\n\t\t</thead>\n\t\t<tbody>\n\t\t');  _.each(data, function(custAct) { ; __p.push(' \n\t\t\t<tr class=\'activity ',  custAct.id ,'\'>\n\t\t\t\t<td>  ',  custAct.title,' </td>\n\t\t\t\t<td>  ',  custAct.content,' </td>\n\t\t\t\t<td>  ',  custAct.time,' </td>\n\t\t\t\t<td>  <button class=\'del-btn\' id=\'',  custAct.id ,'\'>Delete</button> </td>\n\t\t\t</tr>\n\t\t\t');  }); ; __p.push('\n\t\t</tbody> \n\t</table> </br>\n\n\t<footer> \n\t\t<a href=\'/tempo#createCustomActivity\' id=\'add\'> Create a \tCustom Activity </a>\n\t</footer>\n</div>\n');}return __p.join('');};
}).call(this);