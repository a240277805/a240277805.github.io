---
title:
---
# maven-settings.xml


```xml


<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <localRepository>/Users/root-admin/Desktop/zmk-workspace/javaLocalRepository</localRepository>
    <interactiveMode>true</interactiveMode>
    <offline>false</offline>
    <pluginGroups></pluginGroups>
    <proxies></proxies>
    <!--   <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties> -->
    <!--服务用户配置-->
    <servers>
        <server>
            <id>rdc-releases</id>
            <username>61d7de8a8c4a398a0577dc9b</username>
            <password>NXN8IiOADY[1</password>
        </server>
        <server>
            <id>rdc-snapshots</id>
            <username>61d7de8a8c4a398a0577dc9b</username>
            <password>NXN8IiOADY[1</password>
        </server>
    </servers>
    <!--镜像配置-->
    <mirrors>
        <mirror>
            <id>mirror</id>
            <mirrorOf>central,jcenter,!rdc-releases,!rdc-snapshots</mirrorOf>
            <name>mirror</name>
            <url>https://maven.aliyun.com/nexus/content/groups/public</url>
        </mirror>
    </mirrors>
    <profiles>
        <profile>
            <id>rdc</id>
            <properties>
                <altReleaseDeploymentRepository>
                    rdc-releases::default::https://packages.aliyun.com/maven/repository/2175619-release-Gvs1pk/
                </altReleaseDeploymentRepository>
                <altSnapshotDeploymentRepository>
                    rdc-snapshots::default::https://packages.aliyun.com/maven/repository/2175619-snapshot-xhg0U4/
                </altSnapshotDeploymentRepository>
            </properties>
        </profile>
    </profiles>
    <!-- 激活profiles配置 -->
    <activeProfiles>
        <activeProfile>rdc</activeProfile>
    </activeProfiles>
</settings>


```