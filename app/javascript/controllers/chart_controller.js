import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { data: Object }

  connect() {
    const canvas = this.element.querySelector("canvas")
    if (!canvas) return

    // Wait for Chart.js to be available (UMD bundle loads it on window)
    if (!window.Chart) {
      console.error("Chart.js not loaded")
      return
    }

    const ctx = canvas.getContext("2d")
    const data = this.dataValue

    // Define colors and point styles for each dataset
    // Blue/Purple spectrum for SolidQueue, Red/Orange spectrum for GoodJob
    const datasets = [
      {
        label: "SolidQueue Bulk",
        data: data.solidQueueBulk || [],
        backgroundColor: "rgba(59, 130, 246, 0.6)", // Blue
        borderColor: "rgba(59, 130, 246, 1)",
        pointRadius: 7,
        pointStyle: "circle",
      },
      {
        label: "SolidQueue 1-by-1",
        data: data.solidQueueOneByOne || [],
        backgroundColor: "rgba(147, 51, 234, 0.6)", // Purple
        borderColor: "rgba(147, 51, 234, 1)",
        pointRadius: 7,
        pointStyle: "rect",
      },
      {
        label: "GoodJob Bulk",
        data: data.goodJobBulk || [],
        backgroundColor: "rgba(239, 68, 68, 0.6)", // Red
        borderColor: "rgba(239, 68, 68, 1)",
        pointRadius: 7,
        pointStyle: "circle",
      },
      {
        label: "GoodJob 1-by-1",
        data: data.goodJobOneByOne || [],
        backgroundColor: "rgba(249, 115, 22, 0.6)", // Orange
        borderColor: "rgba(249, 115, 22, 1)",
        pointRadius: 7,
        pointStyle: "rect",
      },
    ]

    const ChartClass = window.Chart
    this.chart = new ChartClass(ctx, {
      type: "scatter",
      data: { datasets },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          x: {
            type: "logarithmic",
            title: {
              display: true,
              text: "Number of Jobs",
            },
            min: 500, // Start slightly below 1k for better visibility
            ticks: {
              callback: function (value) {
                if (value >= 1000000) {
                  return (value / 1000000).toFixed(1) + "M"
                } else if (value >= 1000) {
                  return (value / 1000).toFixed(0) + "k"
                }
                return value
              },
              maxTicksLimit: 10,
            },
          },
          y: {
            type: "logarithmic",
            title: {
              display: true,
              text: "Run Duration",
            },
            min: 1, // Start at 1 second
            ticks: {
              callback: function (value) {
                // Format duration in human-readable units
                if (value >= 3600) {
                  const hours = value / 3600
                  return hours % 1 === 0 ? hours + "h" : hours.toFixed(1) + "h"
                } else if (value >= 60) {
                  const minutes = value / 60
                  return minutes % 1 === 0 ? minutes + "m" : minutes.toFixed(1) + "m"
                } else {
                  return value % 1 === 0 ? value + "s" : value.toFixed(1) + "s"
                }
              },
              maxTicksLimit: 12,
            },
          },
        },
        plugins: {
          legend: {
            display: true,
            position: "top",
            labels: {
              usePointStyle: true,
              padding: 15,
              font: {
                size: 12,
              },
            },
          },
          tooltip: {
            callbacks: {
              title: function (context) {
                return `${context[0].raw.x.toLocaleString()} jobs`
              },
              label: function (context) {
                const duration = context.raw.y
                const hours = Math.floor(duration / 3600)
                const minutes = Math.floor((duration % 3600) / 60)
                const seconds = Math.floor(duration % 60)
                let timeStr = ""
                if (hours > 0) timeStr += `${hours}h `
                if (minutes > 0) timeStr += `${minutes}m `
                timeStr += `${seconds}s`
                return `${context.dataset.label}: ${timeStr}`
              },
            },
          },
        },
      },
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }
}
