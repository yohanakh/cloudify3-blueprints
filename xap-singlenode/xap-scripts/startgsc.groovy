import org.openspaces.admin.AdminFactory
import org.openspaces.admin.gsa.GridServiceContainerOptions
import java.net.NetworkInterface

vmargs=null
if(args.length>0){
	vmargs=args[0].trim().split(" ")
}

//Starts a GSC on the local node with args[0] specifying the
//zone

e=NetworkInterface.getByName("eth0").getInetAddresses()
ip=null
while(e.hasMoreElements()){
	addr=e.nextElement()
	if (addr instanceof java.net.Inet4Address)ip=addr.hostAddress
}

if (ip==null) throw new RuntimeException("no ip found")

admin=new AdminFactory().addLocator(ip).useDaemonThreads(true).create()

admin.gridServiceAgents.waitForAtLeastOne()

agt=admin.gridServiceAgents.agents[0]

opts=new GridServiceContainerOptions()
if(vmargs!=null){
	vmargs.each{
		println it
		opts.vmInputArgument(it)
	}
}

agt.startGridService(opts)

