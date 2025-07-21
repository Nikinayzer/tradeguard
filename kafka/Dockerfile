FROM bitnami/kafka:latest

USER root
COPY create-topics.sh /create-topics.sh
RUN chmod +x /create-topics.sh && \
    sed -i 's/\r$//' /create-topics.sh
USER 1001

ENTRYPOINT ["/create-topics.sh"] 
