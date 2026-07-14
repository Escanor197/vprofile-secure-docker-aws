FROM rabbitmq:3.13

LABEL org.opencontainers.image.title="VProfile RabbitMQ" \
      org.opencontainers.image.description="RabbitMQ broker using runtime secrets and a dedicated virtual host"

USER root
COPY docker/rabbitmq/secure-entrypoint.sh /usr/local/bin/vprofile-rabbitmq-entrypoint
RUN chmod 0755 /usr/local/bin/vprofile-rabbitmq-entrypoint

ENTRYPOINT ["/usr/local/bin/vprofile-rabbitmq-entrypoint"]
CMD ["rabbitmq-server"]
