# Auto Update HAProxy for Aurora Cluster events to serve a single dynamic end point true to the Aurora cluster state with PgBouncer as sidecar

Contents of the folder
Name 	   			Description
README.md  			This readme file
monitor_aurora			The shell script demonstartor / reference to build automation so that HAProxy always points to readers
				and automatically add or remove servers based on what is reported by Aurora API for the cluster
monitor_haproxy			Directory housing registry of clusters served by HAProxy and modified and created by monitor_auror script
				Also contains a staging directory with template files for HAproxy configuration
db_healthcheck			Directory that has sample reference shell script used by the HAProxy configuration file for the external-check keyword
pgbouncer			Directory contains sample/reference pgbouncer.ini configuration file , also contains a systemd unit file for use.
haproxy				Directory contains the systemd unit file for HAProxy
iam				Sample EC2 Instance profile  in JSON format with a readme file for guidance on Resource directive. To be used as instance profile for the EC2 machines serving the NLB in this setup so that they can call Aurora API and track state changes
THIRD-PARTY-LICENSES.txt  References to 3rd party files

Instructions
1. Pick a base AMI and install PgBouncer and HAProxy on it .
2. Install AWS CLI on the machine
3. Attach EC2 profile to the machine after ensuring that you have added the Aurora clusters that you will frontend with this setup in the Resources tag for the EC2 profile  defnition
4. Copy monitor_haproxy folder to /etc/ . Ensure that it is owned by the OS user that can manage and execute systemd functions for stop / restart and reload of HAProxy
5. Copy the contents of the db_healthcheck folder and ensure it is in the PATH of the OS user administering HAProxy
6. Check systemd unit files for pgbouncer and HAProxy
7. create / update pgbouncer configuration for the clusters you want to support
8. Configure the setup using the monitor_aurora to add the clusters to the registry .( run monitor_aurora -h for help with configuration actions)
9. Setup cron job to call monitor_aurora to run automtically * (desirably between 1-6 mins)
10. Create an AMI of the setup once validated and use in the target group attached to the NLB


NLB will route connections to the port that PgBouncer and PgBouncer will be configured for each Cluster pointing to the localhost but port will be specific to a given cluster configuration setup on HAProxy

Flow

----->NLB----->PbBouncer DB Port ------> Localhost HAproxy port for given cluster ------> HAProxy forwards connections to different Aurora readers of the cluster

HAProxy is configured by the monitor_aurora script and continuously monitored as a result of the Cron.

Each Aurora cluster has a configuration file for HAProxy.

postgresqlchk script file ensures that writers do not get live traffic and connections are forwarded only when the reader is ready to accept connections.

License

This library is licensed under the MIT-0 License. See the LICENSE file
