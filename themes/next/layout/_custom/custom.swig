{# 鼠标点击特效 #}
{% if theme.cursor_effect == "fireworks" %}
    <script async src="{{ url_for(theme.js) }}/src/cursor/fireworks.js"></script>
{% elseif theme.cursor_effect == "explosion" %}
    <canvas class="fireworks" style="position: fixed;left: 0;top: 0;z-index: 1; pointer-events: none;" ></canvas>
    <script src="//cdn.bootcss.com/animejs/2.2.0/anime.min.js"></script>
    <script async src="{{ url_for(theme.js) }}/src/cursor/explosion.min.js"></script>
{% elseif theme.cursor_effect == "love" %}
    <script async src="{{ url_for(theme.js) }}/src/cursor/love.min.js"></script>
{% elseif theme.cursor_effect == "text" %}
    <script async src="{{ url_for(theme.js) }}/src/cursor/text.js"></script>
{% endif %}