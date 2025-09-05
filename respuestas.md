### Qué partes del código generaste o modificaste con la ayuda de IA.
- La parte de LLM con Gemini
- Refactor de los view components, mejora de estilos.
- Tests
### Cómo hiciste la validación de ese código (¿lo revisaste línea por línea?, ¿ejecutaste pruebas?, ¿lo modificaste?).
Fue hecho con cursor, asique aceptaba o rechazaba según correspondía y con pruebas de la funcionalidad en la misma página, también hice cambios o nuevas sugerencias sobre lo realizado
### Por qué tomaste ciertas decisiones de diseño o arquitectura, incluso si la IA las sugirió. Por ejemplo, "La IA me propuso usar este ORM, pero lo modifiqué para que se ajustara a nuestra base de datos".
Dentro de la arquitectura tome disciones por ejemplo uso de tokens, para tener mas seguridad sobretodo con lo de turbo y tener websockets, como en la parte de comentarios, para no utulizar tokens, tambien pensando en una posible mejora a futuro, considerando sesiones por usuario, que no fue implementado en este momento.
### Alguna parte del código que consideres que la IA te generó de forma "incorrecta" o que tuviste que reajustar para que funcionara como esperabas.
Lo de llamado a Gemini en si no me gustó mucho, ya que hizo todo el servicio de estimación con la conexión a Gemini en el mismo servicio, lo que no permite buena escalabilidad, entonces hice refactor para que el llamado a Gemini estuviese aislado, y desde el servicio de estimación solo se cree el prompt y se trabaje el resultado. Lo que genera que podamos utilizar el serivcio de Gemini para otras cosas a futuro.
También partes de UX/UI, que fui definiendo de a poco.
### Cuánto tiempo te tomó hacer el ejercicio.
Trabaje por 3 días, martes 2 a jueves 4, 3 horas diarias, entonces 9 horas aproximadamente.