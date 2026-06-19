terraform {
  required_providers {

    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }

  }
}


provider "docker" {}


# -------------------------
# Docker Network
# -------------------------

resource "docker_network" "wordpress_network" {

  name = "wordpress-network"

}


# -------------------------
# MySQL Volume
# -------------------------

resource "docker_volume" "mysql_data" {

  name = "wordpress-mysql-data"

}


# -------------------------
# MySQL Container
# -------------------------

resource "docker_container" "mysql" {

  name  = "mysql"
  image = docker_image.mysql.image_id


  networks_advanced {

    name = docker_network.wordpress_network.name

  }


  env = [

    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wpuser",
    "MYSQL_PASSWORD=password",
    "MYSQL_ROOT_PASSWORD=rootpass"

  ]


  volumes {

    volume_name = docker_volume.mysql_data.name
    container_path = "/var/lib/mysql"

  }


}


# -------------------------
# WordPress Image
# -------------------------

resource "docker_image" "wordpress" {

  name = "wordpress:latest"

}


# -------------------------
# MySQL Image
# -------------------------

resource "docker_image" "mysql" {

  name = "mysql:8"

}


# -------------------------
# Nginx Image
# -------------------------

resource "docker_image" "nginx" {

  name = "nginx:latest"

}


# -------------------------
# WordPress Container
# -------------------------

resource "docker_container" "wordpress" {


  name = "wordpress"


  image = docker_image.wordpress.image_id


  depends_on = [
    docker_container.mysql
  ]


  networks_advanced {

    name = docker_network.wordpress_network.name

  }


  ports {

    internal = 80
    external = 8080

  }


  env = [

    "WORDPRESS_DB_HOST=mysql",
    "WORDPRESS_DB_USER=wpuser",
    "WORDPRESS_DB_PASSWORD=password",
    "WORDPRESS_DB_NAME=wordpress",

    "WORDPRESS_CONFIG_EXTRA=define('WP_HOME','http://localhost'); define('WP_SITEURL','http://localhost');"

  ]


}


# -------------------------
# Nginx Container
# -------------------------

resource "docker_container" "nginx" {


  name = "nginx"


  image = docker_image.nginx.image_id


  depends_on = [

    docker_container.wordpress

  ]


  networks_advanced {

    name = docker_network.wordpress_network.name

  }


  ports {

    internal = 80
    external = 80

  }


  volumes {

    host_path      = "${path.cwd}/../docker/nginx.conf"
    container_path = "/etc/nginx/nginx.conf"

  }


}