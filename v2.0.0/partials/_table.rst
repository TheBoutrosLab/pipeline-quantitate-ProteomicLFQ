+{{'-'*data['widths'][0]}}+{{'-'*data['widths'][1]}}+{{'-'*data['widths'][2]}}+
| Parameter{{ ' ' * (data['widths'][0]-10) }}| Type{{ ' ' * (data['widths'][1]-5) }}| Description{{' ' * (data['widths'][2]-12)}}|
+{{'='*data['widths'][0]}}+{{'='*data['widths'][1]}}+{{'='*data['widths'][2]}}+
{% for param in data['params'] %}{% for line in param %}|| {{line[0]}} || {{line[1]}} || {{line[2]}} |
{% endfor %}+{{'-'*data['widths'][0]}}+{{'-'*data['widths'][1]}}+{{'-'*data['widths'][2]}}+
{% endfor %}
