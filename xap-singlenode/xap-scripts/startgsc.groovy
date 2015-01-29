import org.openspaces.admin.AdminFactory
import org.openspaces.admin.gsa.GridServiceContainerOptions
import java.net.NetworkInterface

vmargs=null
if(args.length>0){
	vmargs=args[0].trim().split(" ")
}

//Starts a GSC on the local node with args[0] specifying the
//zone
interfacename=System.getProperty("interfacename", "eth0")
assert (System.getProperty("gsc_cnt") != null), "gsc_cnt cannot be empty"
gsc_cnt=Integer.valueOf(System.getProperty("gsc_cnt"))
e=NetworkInterface.getByName(interfacename).getInetAddresses()
ip=null
while(e.hasMoreElements()){
	addr=e.nextElement()
	if (addr instanceof java.net.Inet4Address)ip=addr.hostAddress
}

if (ip==null) throw new RuntimeException("no ip found")

admin=new AdminFactory().addLocator(ip).useDaemonThreads(true).create()

admin.gridServiceAgents.waitForAtLeastOne()

agt=admin.gridServiceAgents.agents[0]

println "Should start " +gsc_cnt +" GSCs"
for (int i=0; i<gsc_cnt ;i++) {
opts=new GridServiceContainerOptions()
if(vmargs!=null){
	vmargs.each{
		println it
		opts.vmInputArgument(it)
	}
}
println "STarting GSC"
agt.startGridServiceAndWait(opts)
}

println "Finished starting GSCs!"