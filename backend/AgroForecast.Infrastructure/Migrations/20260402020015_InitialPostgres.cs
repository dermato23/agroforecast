using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace AgroForecast.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class InitialPostgres : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Categories",
                columns: table => new
                {
                    CategoryID = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CategoryName = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Categories", x => x.CategoryID);
                });

            migrationBuilder.CreateTable(
                name: "Markets",
                columns: table => new
                {
                    MarketID = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    MarketName = table.Column<string>(type: "text", nullable: false),
                    City = table.Column<string>(type: "text", nullable: false),
                    Region = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Markets", x => x.MarketID);
                });

            migrationBuilder.CreateTable(
                name: "SourceTypes",
                columns: table => new
                {
                    SourceTypeID = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    SourceName = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SourceTypes", x => x.SourceTypeID);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    UserID = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Email = table.Column<string>(type: "text", nullable: false),
                    AvatarStr = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.UserID);
                });

            migrationBuilder.CreateTable(
                name: "Products",
                columns: table => new
                {
                    ProductID = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CategoryID = table.Column<int>(type: "integer", nullable: false),
                    StandardName = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true),
                    BaseUnit = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Products", x => x.ProductID);
                    table.ForeignKey(
                        name: "FK_Products_Categories_CategoryID",
                        column: x => x.CategoryID,
                        principalTable: "Categories",
                        principalColumn: "CategoryID");
                });

            migrationBuilder.CreateTable(
                name: "PriceForecasts",
                columns: table => new
                {
                    ForecastID = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ProductID = table.Column<int>(type: "integer", nullable: false),
                    MarketID = table.Column<int>(type: "integer", nullable: false),
                    ForecastDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    PredictedAvgPrice = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    ConfidenceScore = table.Column<decimal>(type: "numeric(5,2)", nullable: true),
                    Recommendation = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PriceForecasts", x => x.ForecastID);
                    table.ForeignKey(
                        name: "FK_PriceForecasts_Markets_MarketID",
                        column: x => x.MarketID,
                        principalTable: "Markets",
                        principalColumn: "MarketID");
                    table.ForeignKey(
                        name: "FK_PriceForecasts_Products_ProductID",
                        column: x => x.ProductID,
                        principalTable: "Products",
                        principalColumn: "ProductID");
                });

            migrationBuilder.CreateTable(
                name: "PriceLogs",
                columns: table => new
                {
                    PriceLogID = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ProductID = table.Column<int>(type: "integer", nullable: false),
                    MarketID = table.Column<int>(type: "integer", nullable: false),
                    SourceTypeID = table.Column<int>(type: "integer", nullable: false),
                    ReportDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    MinPrice = table.Column<decimal>(type: "numeric(18,2)", nullable: true),
                    MaxPrice = table.Column<decimal>(type: "numeric(18,2)", nullable: true),
                    AvgPrice = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    ReportedUnit = table.Column<string>(type: "text", nullable: false),
                    StandardizedPricePerKg = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PriceLogs", x => x.PriceLogID);
                    table.ForeignKey(
                        name: "FK_PriceLogs_Markets_MarketID",
                        column: x => x.MarketID,
                        principalTable: "Markets",
                        principalColumn: "MarketID");
                    table.ForeignKey(
                        name: "FK_PriceLogs_Products_ProductID",
                        column: x => x.ProductID,
                        principalTable: "Products",
                        principalColumn: "ProductID");
                    table.ForeignKey(
                        name: "FK_PriceLogs_SourceTypes_SourceTypeID",
                        column: x => x.SourceTypeID,
                        principalTable: "SourceTypes",
                        principalColumn: "SourceTypeID");
                });

            migrationBuilder.CreateTable(
                name: "ProductAliases",
                columns: table => new
                {
                    AliasID = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    OriginalName = table.Column<string>(type: "text", nullable: false),
                    SourceTypeID = table.Column<int>(type: "integer", nullable: false),
                    ProductID = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProductAliases", x => x.AliasID);
                    table.ForeignKey(
                        name: "FK_ProductAliases_Products_ProductID",
                        column: x => x.ProductID,
                        principalTable: "Products",
                        principalColumn: "ProductID");
                    table.ForeignKey(
                        name: "FK_ProductAliases_SourceTypes_SourceTypeID",
                        column: x => x.SourceTypeID,
                        principalTable: "SourceTypes",
                        principalColumn: "SourceTypeID");
                });

            migrationBuilder.CreateTable(
                name: "SavingsLogs",
                columns: table => new
                {
                    SavingsLogID = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserID = table.Column<int>(type: "integer", nullable: false),
                    ProductID = table.Column<int>(type: "integer", nullable: false),
                    Date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    SavedAmount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    KilosBought = table.Column<decimal>(type: "numeric(18,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SavingsLogs", x => x.SavingsLogID);
                    table.ForeignKey(
                        name: "FK_SavingsLogs_Products_ProductID",
                        column: x => x.ProductID,
                        principalTable: "Products",
                        principalColumn: "ProductID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SavingsLogs_Users_UserID",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserFavorites",
                columns: table => new
                {
                    FavoriteID = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserID = table.Column<int>(type: "integer", nullable: false),
                    ProductID = table.Column<int>(type: "integer", nullable: false),
                    MarketID = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserFavorites", x => x.FavoriteID);
                    table.ForeignKey(
                        name: "FK_UserFavorites_Markets_MarketID",
                        column: x => x.MarketID,
                        principalTable: "Markets",
                        principalColumn: "MarketID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserFavorites_Products_ProductID",
                        column: x => x.ProductID,
                        principalTable: "Products",
                        principalColumn: "ProductID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserFavorites_Users_UserID",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Categories_CategoryName",
                table: "Categories",
                column: "CategoryName",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PriceForecasts_MarketID",
                table: "PriceForecasts",
                column: "MarketID");

            migrationBuilder.CreateIndex(
                name: "IX_PriceForecasts_ProductID_ForecastDate",
                table: "PriceForecasts",
                columns: new[] { "ProductID", "ForecastDate" });

            migrationBuilder.CreateIndex(
                name: "IX_PriceLogs_MarketID",
                table: "PriceLogs",
                column: "MarketID");

            migrationBuilder.CreateIndex(
                name: "IX_PriceLogs_ProductID_ReportDate",
                table: "PriceLogs",
                columns: new[] { "ProductID", "ReportDate" });

            migrationBuilder.CreateIndex(
                name: "IX_PriceLogs_SourceTypeID",
                table: "PriceLogs",
                column: "SourceTypeID");

            migrationBuilder.CreateIndex(
                name: "IX_ProductAliases_OriginalName_SourceTypeID",
                table: "ProductAliases",
                columns: new[] { "OriginalName", "SourceTypeID" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ProductAliases_ProductID",
                table: "ProductAliases",
                column: "ProductID");

            migrationBuilder.CreateIndex(
                name: "IX_ProductAliases_SourceTypeID",
                table: "ProductAliases",
                column: "SourceTypeID");

            migrationBuilder.CreateIndex(
                name: "IX_Products_CategoryID",
                table: "Products",
                column: "CategoryID");

            migrationBuilder.CreateIndex(
                name: "IX_Products_StandardName",
                table: "Products",
                column: "StandardName",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SavingsLogs_ProductID",
                table: "SavingsLogs",
                column: "ProductID");

            migrationBuilder.CreateIndex(
                name: "IX_SavingsLogs_UserID",
                table: "SavingsLogs",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_SourceTypes_SourceName",
                table: "SourceTypes",
                column: "SourceName",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserFavorites_MarketID",
                table: "UserFavorites",
                column: "MarketID");

            migrationBuilder.CreateIndex(
                name: "IX_UserFavorites_ProductID",
                table: "UserFavorites",
                column: "ProductID");

            migrationBuilder.CreateIndex(
                name: "IX_UserFavorites_UserID_ProductID_MarketID",
                table: "UserFavorites",
                columns: new[] { "UserID", "ProductID", "MarketID" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PriceForecasts");

            migrationBuilder.DropTable(
                name: "PriceLogs");

            migrationBuilder.DropTable(
                name: "ProductAliases");

            migrationBuilder.DropTable(
                name: "SavingsLogs");

            migrationBuilder.DropTable(
                name: "UserFavorites");

            migrationBuilder.DropTable(
                name: "SourceTypes");

            migrationBuilder.DropTable(
                name: "Markets");

            migrationBuilder.DropTable(
                name: "Products");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "Categories");
        }
    }
}
