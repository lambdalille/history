# Lambda Lille : historique des présentations

{%- for event in events %}

## {{ event.name }}

{{ event.date.canonical }}
{% if event.place -%}
à {% if event.place.website %}[{{ event.place.name }}]({{ event.place.website }}){% else %}{{ event.place.name }}{% endif %}
(_{{ event.place.address  }}_)
{%- endif %}

**Lien de l'événement:** [{{ event.link.name }}]({{ event.link.href  }})

{% for talk in event.talks -%}

- **{{ talk.title }}** ({{ talk.lang | upper }}), par
  {% for speaker in talk.speakers -%}
  {%- if speaker.main_link -%}
  [{{ speaker.fullname }}]({{ speaker.main_link }})
  {%- else -%}{{ speaker.fullname }}
  {%- endif -%}
  {%- if not loop.last -%}, {% else %}.{% endif -%}
  {% endfor %}  
  {% if talk.video_link -%}[Vidéo]({{talk.video_link}}){%- endif %}
  {% if talk.support_link -%}[Support]({{talk.support_link}}){%- endif %}

{% endfor %}
{% endfor %}