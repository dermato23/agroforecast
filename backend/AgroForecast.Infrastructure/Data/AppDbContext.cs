using AgroForecast.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace AgroForecast.Infrastructure.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Category> Categories { get; set; } = null!;
    public DbSet<Market> Markets { get; set; } = null!;
    public DbSet<Product> Products { get; set; } = null!;
    public DbSet<ProductAlias> ProductAliases { get; set; } = null!;
    public DbSet<SourceType> SourceTypes { get; set; } = null!;
    public DbSet<PriceLog> PriceLogs { get; set; } = null!;
    public DbSet<PriceForecast> PriceForecasts { get; set; } = null!;
    public DbSet<User> Users { get; set; } = null!;
    public DbSet<UserFavorite> UserFavorites { get; set; } = null!;
    public DbSet<SavingsLog> SavingsLogs { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.CategoryID);
            entity.HasIndex(e => e.CategoryName).IsUnique();
        });

        modelBuilder.Entity<Market>(entity =>
        {
            entity.HasKey(e => e.MarketID);
        });

        modelBuilder.Entity<SourceType>(entity =>
        {
            entity.HasKey(e => e.SourceTypeID);
            entity.HasIndex(e => e.SourceName).IsUnique();
        });

        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.ProductID);
            entity.HasIndex(e => e.StandardName).IsUnique();
            
            entity.HasOne(d => d.Category)
                .WithMany(p => p.Products)
                .HasForeignKey(d => d.CategoryID)
                .OnDelete(DeleteBehavior.ClientSetNull);
        });

        modelBuilder.Entity<ProductAlias>(entity =>
        {
            entity.HasKey(e => e.AliasID);
            entity.HasIndex(e => new { e.OriginalName, e.SourceTypeID }).IsUnique();

            entity.HasOne(d => d.Product)
                .WithMany(p => p.ProductAliases)
                .HasForeignKey(d => d.ProductID)
                .OnDelete(DeleteBehavior.ClientSetNull);

            entity.HasOne(d => d.SourceType)
                .WithMany(p => p.ProductAliases)
                .HasForeignKey(d => d.SourceTypeID)
                .OnDelete(DeleteBehavior.ClientSetNull);
        });

        modelBuilder.Entity<PriceLog>(entity =>
        {
            entity.HasKey(e => e.PriceLogID);
            entity.HasIndex(e => new { e.ProductID, e.ReportDate });

            entity.Property(e => e.AvgPrice).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.MaxPrice).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.MinPrice).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.StandardizedPricePerKg).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Market)
                .WithMany(p => p.PriceLogs)
                .HasForeignKey(d => d.MarketID)
                .OnDelete(DeleteBehavior.ClientSetNull);

            entity.HasOne(d => d.Product)
                .WithMany(p => p.PriceLogs)
                .HasForeignKey(d => d.ProductID)
                .OnDelete(DeleteBehavior.ClientSetNull);

            entity.HasOne(d => d.SourceType)
                .WithMany(p => p.PriceLogs)
                .HasForeignKey(d => d.SourceTypeID)
                .OnDelete(DeleteBehavior.ClientSetNull);
        });

        modelBuilder.Entity<PriceForecast>(entity =>
        {
            entity.HasKey(e => e.ForecastID);
            entity.HasIndex(e => new { e.ProductID, e.ForecastDate });

            entity.Property(e => e.ConfidenceScore).HasColumnType("decimal(5, 2)");
            entity.Property(e => e.PredictedAvgPrice).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Market)
                .WithMany(p => p.PriceForecasts)
                .HasForeignKey(d => d.MarketID)
                .OnDelete(DeleteBehavior.ClientSetNull);

            entity.HasOne(d => d.Product)
                .WithMany(p => p.PriceForecasts)
                .HasForeignKey(d => d.ProductID)
                .OnDelete(DeleteBehavior.ClientSetNull);
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UserID);
            entity.HasIndex(e => e.Email).IsUnique();
        });

        modelBuilder.Entity<UserFavorite>(entity =>
        {
            entity.HasKey(e => e.FavoriteID);
            entity.HasIndex(e => new { e.UserID, e.ProductID, e.MarketID }).IsUnique();

            entity.HasOne(d => d.User)
                .WithMany(p => p.UserFavorites)
                .HasForeignKey(d => d.UserID);

            entity.HasOne(d => d.Product)
                .WithMany()
                .HasForeignKey(d => d.ProductID);

            entity.HasOne(d => d.Market)
                .WithMany()
                .HasForeignKey(d => d.MarketID);
        });

        modelBuilder.Entity<SavingsLog>(entity =>
        {
            entity.HasKey(e => e.SavingsLogID);
            
            entity.Property(e => e.SavedAmount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.KilosBought).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.User)
                .WithMany(p => p.SavingsLogs)
                .HasForeignKey(d => d.UserID);

            entity.HasOne(d => d.Product)
                .WithMany()
                .HasForeignKey(d => d.ProductID);
        });
    }
}
