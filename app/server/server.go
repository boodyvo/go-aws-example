package server

import (
	"log"
	"net/http"
	"sync/atomic"
	"time"

	"github.com/gin-gonic/gin"
)

type Server struct {
	counter int64

	server *http.Server
	router *gin.Engine
}

// New creates an instance of a gin server with health check and counter endpoint
func New() *Server {
	router := gin.Default()
	server := &Server{
		router:  router,
		counter: int64(0),
	}

	router.GET("/", server.CounterHandler)
	router.GET("/health", server.HealthHandler)

	return server
}

// HealthHandler returns a success message with code 200 when the server is running
func (s *Server) HealthHandler(ctx *gin.Context) {
	ctx.JSON(200, gin.H{"success": true})
}

// CounterHandler calculates number of requests and return a json with counter number
func (s *Server) CounterHandler(ctx *gin.Context) {
	counter := atomic.AddInt64(&s.counter, 1)

	ctx.JSON(200, gin.H{"counter": counter})
}

// Start starts the server and listen on a provided address in a format <host>:<port>
func (s *Server) Start(address string) error {
	s.server = &http.Server{
		Addr:        address,
		Handler:     s.router,
		ReadTimeout: 10 * time.Second,
	}

	log.Printf("start server on %s", address)

	return s.server.ListenAndServe()
}

// Stop stops the server
func (s *Server) Stop() error {
	log.Printf("stop server")

	if s.server != nil {
		return s.server.Close()
	}

	return nil
}
