## grafana


### setup grafana

* open `http://localhost:3000` and login with admin/admin 
* change password
* navigate to `data sources`
* change query language to `Flux`
* switch off `basic auth` 
* adjust `URL Address` - ip adress of the host
* insert bucketname `.env`
* insert organisation `.env`
* insert influxdb2 apptoken `.env`
* save and test configuration

### add data to graph

* create new dashboard
* extract query from querybuilder of influxdb2 webinterface
* save dashboard
