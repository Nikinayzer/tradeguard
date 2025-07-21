#!/bin/bash

# Wait for Kafka to be ready
echo "Waiting for Kafka to be ready..."
while ! kafka-topics.sh --bootstrap-server kafka:9092 --list; do
  echo "Kafka is not ready yet. Retrying in 5 seconds..."
  sleep 5
done

# Create topics
echo "Creating Kafka topics..."

# Job submissions topic
kafka-topics.sh --bootstrap-server kafka:9092 --create --topic job-submissions --partitions 3 --replication-factor 1 --if-not-exists

# Job updates topic
kafka-topics.sh --bootstrap-server kafka:9092 --create --topic job-updates --partitions 3 --replication-factor 1 --if-not-exists

# Risk notifications topic
kafka-topics.sh --bootstrap-server kafka:9092 --create --topic risk-notifications --partitions 3 --replication-factor 1 --if-not-exists

# Position updates topic
kafka-topics.sh --bootstrap-server kafka:9092 --create --topic position-updates --partitions 3 --replication-factor 1 --if-not-exists

# Equity topic
kafka-topics.sh --bootstrap-server kafka:9092 --create --topic equity --partitions 3 --replication-factor 1 --if-not-exists

# Order flow topic
kafka-topics.sh --bootstrap-server kafka:9092 --create --topic order-flow --partitions 3 --replication-factor 1 --if-not-exists

# Market data topic
kafka-topics.sh --bootstrap-server kafka:9092 --create --topic market-data --partitions 3 --replication-factor 1 --if-not-exists

echo "All topics created successfully!" 
