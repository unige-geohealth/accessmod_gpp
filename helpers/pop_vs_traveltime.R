library(ggplot2)

# Function to plot cumulative sum of population
plot_cumulative_sum <- function(data, pdf_path) {
  # Create ggplot object

  pdf(file = pdf_path, width = 210 / 25.4, height = 148 / 25.4)


  plot(data$zone, data$cumSum,
    type = "o", col = "black", pch = 19, lwd = 2,
    main = "Population Access to Green Areas by Travel Time",
    xlab = "Travel Time Zone",
    ylab = "Cumulative Population"
  )



  # Close the device
  dev.off()
}
