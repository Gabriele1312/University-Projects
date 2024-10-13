package it.innotechsys.smarthome.drivers;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;

//server che gestisce le richieste TCP da node-red
public class TCPServerDriver {

    public TCPServerDriver() {
        TCPDriverInstance tcpInstance = TCPDriverInstance.getInstance();
        try {
            ServerSocket serverSocketR = new ServerSocket(9090);
            System.out.println("Server started on port 9090");
            //noinspection InfiniteLoopStatement
            while(true) {
                Socket clientSocketR = serverSocketR.accept();
                //System.out.println("New client connected: " + clientSocketR.getInetAddress().getHostAddress());
                tcpInstance.setClientSocketR(clientSocketR);
                new Thread(tcpInstance).start();
            }
        } catch (IOException e) {
            System.err.println("Error in TCPServerDriver: " + e.getMessage());
        }
    }
}