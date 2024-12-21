#!/bin/bash

# Build the Docker image
echo "Building Docker image..."
docker compose build

# Start the Docker containers
echo "Starting Docker containers..."
docker compose up -d

# Wait for the containers to be fully up (optional but recommended)
echo "Waiting for the containers to initialize (MySQL, OpenSearch, Magento)..."
sleep 60

echo "Fixing magento permission problems..."

docker exec -it magento bash -c "find var vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +"
docker exec -it magento bash -c "find var vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +"
docker exec -it magento bash -c "chown -R www-data:www-data ."
docker exec -it magento bash -c "chmod +x bin/magento"

# Run the installation command inside the Magento container
docker exec -it magento bash -c "php -d memory_limit=-1 bin/magento setup:install --db-host=mysql --db-name=magento --db-user=magento --db-password=magento --admin-firstname=admin --admin-lastname=admin --admin-email=admin123@example.com --admin-user=admin --admin-password=admin123 --language=en_US --currency=USD --timezone=America/Chicago --use-rewrites=1 --search-engine=opensearch --opensearch-host=opensearch --opensearch-port=9200"

docker exec -it magento bash -c "php -d memory_limit=-1 bin/magento setup:upgrade"

docker exec -it magento bash -c "php -d memory_limit=-1 bin/magento setup:di:compile"