package main

import (
	"fmt"
	"log"
	"os"

	"github.com/urfave/cli/v2"
	"github.com/xo/dburl"
	"go.uber.org/fx"
	"gorm.io/driver/mysql"
	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var (
	GlobalFlagsInst = &GlobalFalgs{}
)

func main() {
	app := &cli.App{
		Name:   "demo",
		Action: run,
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:        "database-url",
				Usage:       "Database URL",
				EnvVars:     []string{"DATABASE_URL"},
				Required:    true,
				Destination: &GlobalFlagsInst.DatabaseURL,
			},
		},
	}

	if err := app.Run(os.Args); err != nil {
		log.Fatal(err)
	}
}

type GlobalFalgs struct {
	DatabaseURL string
}

func run(cCtx *cli.Context) error {
	app := fx.New(
		fx.Provide(connectDatabase),
		fx.Invoke(
			func(db *gorm.DB) {
				// database migration
				db.AutoMigrate(&User{})

				// insert data
				db.Create(&User{
					Name: "John Doe",
				})
			},
		),
	)

	return app.Start(cCtx.Context)
}

func connectDatabase() (*gorm.DB, error) {
	dbUrl, err := dburl.Parse(GlobalFlagsInst.DatabaseURL)
	if err != nil {
		return nil, err
	}

	switch dbUrl.Driver {
	case "sqlite", "sqlite3":
		return gorm.Open(sqlite.Open(dbUrl.DSN), &gorm.Config{})
	case "mysql", "mariadb":
		return gorm.Open(mysql.Open(dbUrl.DSN), &gorm.Config{})
	case "postgres", "postgresql", "pg":
		return gorm.Open(postgres.Open(dbUrl.DSN), &gorm.Config{})
	default:
		return nil, fmt.Errorf("unsupported database type: %s", dbUrl.Driver)
	}
}
